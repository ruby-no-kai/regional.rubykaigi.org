# frozen_string_literal: true

require "date"
require "minitest/autorun"
require_relative "../../lib/regional_ruby_kaigi/normalizer"

module RegionalRubyKaigi
  class NormalizerTest < Minitest::Test
    def test_merge_appends_kaigis_entries_after_the_legacy_array
      events = [{ "name" => "legacy01", "title" => "Legacy" }]
      kaigis = { "sample02" => { "name" => "sample02", "title" => "Sample" } }

      result = Normalizer.merge(events: events, kaigis: kaigis)

      assert_equal %w[legacy01 sample02], result.map { |event| event["name"] }
    end

    def test_merge_orders_kaigis_entries_by_start_on_not_filename
      kaigis = {
        "a01" => { "name" => "a01", "start_on" => "2027-06-01" },
        "z01" => { "name" => "z01", "start_on" => "2026-01-01" }
      }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      assert_equal %w[z01 a01], result.map { |event| event["name"] }
    end

    def test_merge_orders_kaigis_entries_by_start_on_regardless_of_hash_order
      kaigis = {
        "z01" => { "name" => "z01", "start_on" => "2027-01-01" },
        "a01" => { "name" => "a01", "start_on" => "2026-01-01" }
      }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      assert_equal %w[a01 z01], result.map { |event| event["name"] }
    end

    def test_merge_orders_by_start_on_after_expanding_held_on
      kaigis = {
        "a01" => { "name" => "a01", "held_on" => "2027-06-01" },
        "z01" => { "name" => "z01", "start_on" => "2026-01-01", "end_on" => "2026-01-02" }
      }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      assert_equal %w[z01 a01], result.map { |event| event["name"] }
    end

    def test_merge_fills_in_a_missing_name_from_the_filename
      kaigis = { "noname03" => { "title" => "No Name" } }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      assert_equal "noname03", result.first["name"]
    end

    def test_merge_expands_held_on_into_start_on_and_end_on
      kaigis = { "single01" => { "name" => "single01", "held_on" => Date.new(2027, 4, 1) } }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      entry = result.first
      assert_equal Date.new(2027, 4, 1), entry["start_on"]
      assert_equal Date.new(2027, 4, 1), entry["end_on"]
      refute entry.key?("held_on")
    end

    def test_merge_prefers_held_on_over_stale_start_on_and_end_on
      kaigis = {
        "single02" => {
          "name" => "single02",
          "held_on" => Date.new(2027, 5, 1),
          "start_on" => Date.new(2020, 1, 1),
          "end_on" => Date.new(2020, 1, 2)
        }
      }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      entry = result.first
      assert_equal Date.new(2027, 5, 1), entry["start_on"]
      assert_equal Date.new(2027, 5, 1), entry["end_on"]
    end

    def test_merge_does_not_mutate_its_arguments
      events = [{ "name" => "legacy01" }].freeze
      kaigis = { "sample02" => { "name" => "sample02" } }.freeze

      Normalizer.merge(events: events, kaigis: kaigis)

      assert_equal({ "name" => "legacy01" }, events.first)
      assert_equal({ "name" => "sample02" }, kaigis["sample02"])
    end

    def test_merge_treats_nil_events_and_kaigis_as_empty
      assert_empty Normalizer.merge(events: nil, kaigis: nil)
    end
  end
end
