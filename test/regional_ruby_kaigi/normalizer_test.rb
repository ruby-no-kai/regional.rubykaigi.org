# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../../lib/regional_ruby_kaigi/normalizer"

class RegionalRubyKaigiNormalizerTest < Minitest::Test
  FIXTURE_DIR = File.expand_path("../fixtures/data", __dir__)

  def test_merge_appends_kaigis_entries_after_the_legacy_array
    events = [{ "name" => "legacy01", "title" => "Legacy" }]
    kaigis = { "sample02" => { "name" => "sample02", "title" => "Sample" } }

    result = RegionalRubyKaigi::Normalizer.merge(events: events, kaigis: kaigis)

    assert_equal %w[legacy01 sample02], result.map { |event| event["name"] }
  end

  def test_merge_orders_kaigis_entries_by_filename_regardless_of_hash_order
    kaigis = {
      "z01" => { "name" => "z01" },
      "a01" => { "name" => "a01" }
    }

    result = RegionalRubyKaigi::Normalizer.merge(events: [], kaigis: kaigis)

    assert_equal %w[a01 z01], result.map { |event| event["name"] }
  end

  def test_merge_fills_in_a_missing_name_from_the_filename
    kaigis = { "noname03" => { "title" => "No Name" } }

    result = RegionalRubyKaigi::Normalizer.merge(events: [], kaigis: kaigis)

    assert_equal "noname03", result.first["name"]
  end

  def test_merge_does_not_mutate_its_arguments
    events = [{ "name" => "legacy01" }].freeze
    kaigis = { "sample02" => { "name" => "sample02" } }.freeze

    RegionalRubyKaigi::Normalizer.merge(events: events, kaigis: kaigis)

    assert_equal({ "name" => "legacy01" }, events.first)
    assert_equal({ "name" => "sample02" }, kaigis["sample02"])
  end

  def test_load_reads_events_yml_and_kaigis_from_disk
    result = RegionalRubyKaigi::Normalizer.load(data_dir: FIXTURE_DIR)

    assert_equal %w[legacy01 noname03 sample02], result.map { |event| event["name"] }.sort
    sample = result.find { |event| event["name"] == "sample02" }
    assert_equal Date.new(2021, 2, 2), sample["start_on"]
  end

  def test_load_defaults_to_the_repository_data_directory
    result = RegionalRubyKaigi::Normalizer.load

    assert(result.any? { |event| event["name"] == "tokyo01" })
  end

  def test_load_raises_invalid_data_when_events_yml_is_not_an_array
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "events.yml"), "name: not-an-array\n")

      error = assert_raises(RegionalRubyKaigi::Normalizer::InvalidData) do
        RegionalRubyKaigi::Normalizer.load(data_dir: dir)
      end
      assert_includes error.message, "最上位はイベントの配列にしてください"
    end
  end

  def test_load_raises_invalid_data_on_malformed_yaml
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "events.yml"), "- name: [unterminated\n")

      assert_raises(RegionalRubyKaigi::Normalizer::InvalidData) do
        RegionalRubyKaigi::Normalizer.load(data_dir: dir)
      end
    end
  end
end
