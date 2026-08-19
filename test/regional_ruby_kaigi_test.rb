# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../lib/regional_ruby_kaigi"

class RegionalRubyKaigiTest < Minitest::Test
  FIXTURE_DIR = File.expand_path("fixtures/data", __dir__)

  StubSite = Struct.new(:data)
  StubLoader = Struct.new(:kaigis) do
    def load = kaigis
  end

  def test_normalize_kaigis_merges_a_sites_events_and_kaigis_data
    site = StubSite.new({
      "events" => [{ "name" => "legacy01" }],
      "kaigis" => { "sample02" => { "name" => "sample02" } }
    })

    result = RegionalRubyKaigi.normalize_kaigis(site)

    assert_equal %w[legacy01 sample02], result.map { |event| event["name"] }
  end

  def test_normalize_kaigis_defaults_missing_data_to_empty
    site = StubSite.new({})

    assert_empty RegionalRubyKaigi.normalize_kaigis(site)
  end

  def test_upcoming_selects_and_sorts_by_start_on
    kaigis = [
      { "title" => "Past", "start_on" => Date.new(2026, 1, 1) },
      { "title" => "Later", "start_on" => "2026-03-01" },
      { "title" => "Today", "start_on" => Date.new(2026, 2, 1) }
    ]

    upcoming = RegionalRubyKaigi.upcoming(Date.new(2026, 2, 1), loader: StubLoader.new(kaigis))

    assert_equal %w[Today Later], upcoming.map(&:title)
    assert(upcoming.all? { |kaigi| kaigi.is_a?(RegionalRubyKaigi::Kaigi) })
  end

  def test_upcoming_is_empty_when_nothing_is_upcoming
    kaigis = [{ "title" => "Past", "start_on" => Date.new(2026, 1, 1) }]

    assert_empty RegionalRubyKaigi.upcoming(Date.new(2026, 2, 1), loader: StubLoader.new(kaigis))
  end

  def test_japan_today_uses_the_japan_date_at_the_utc_date_boundary
    now = Time.new(2026, 2, 1, 15, 30, 0, "+00:00")

    assert_equal Date.new(2026, 2, 2), RegionalRubyKaigi.japan_today(now)
  end

  def test_date_accepts_a_date_or_an_iso8601_string
    assert_equal Date.new(2026, 2, 1), RegionalRubyKaigi.date(Date.new(2026, 2, 1))
    assert_equal Date.new(2026, 2, 1), RegionalRubyKaigi.date("2026-02-01")
  end

  def test_validate_kaigis_returns_the_kaigis_when_valid
    kaigis = RegionalRubyKaigi.validate_kaigis!(data_dir: FIXTURE_DIR)

    assert_equal 3, kaigis.length
  end

  def test_validate_kaigis_raises_combining_loader_and_validator_errors
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "events.yml"), "[]\n")
      Dir.mkdir(File.join(dir, "kaigis"))
      # A filename/name mismatch (Loader's job to catch) alongside a
      # missing required field (Validator's job) — both should show up.
      File.write(File.join(dir, "kaigis", "okrk03.yml"), "name: okrk04\ntitle: Oops\n")

      error = assert_raises(RegionalRubyKaigi::ValidationError) do
        RegionalRubyKaigi.validate_kaigis!(data_dir: dir)
      end

      assert(error.errors.any? { |message| message.include?("okrk03.yml") })
      assert(error.errors.any? { |message| message.include?("start_on") })
    end
  end
end
