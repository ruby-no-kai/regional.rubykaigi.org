# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/regional_ruby_kaigi"

class RegionalRubyKaigiTest < Minitest::Test
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
end
