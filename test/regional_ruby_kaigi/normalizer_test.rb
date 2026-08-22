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

    def test_merge_numbers_entries_by_start_on_order_starting_at_1
      events = [{ "name" => "tokyo01", "start_on" => "2008-08-21" }]
      kaigis = { "sapporo01" => { "name" => "sapporo01", "start_on" => "2008-10-25" } }

      result = Normalizer.merge(events: events, kaigis: kaigis)

      assert_equal [1, 2], result.map { |event| event["seq"] }
    end

    def test_merge_numbers_kaigis_entries_by_their_true_start_on_order_even_though_they_are_appended_after_events
      events = [{ "name" => "later", "start_on" => "2030-01-01" }]
      kaigis = { "earlier" => { "name" => "earlier", "start_on" => "2000-01-01" } }

      result = Normalizer.merge(events: events, kaigis: kaigis)

      assert_equal 2, result.find { |event| event["name"] == "later" }["seq"]
      assert_equal 1, result.find { |event| event["name"] == "earlier" }["seq"]
    end

    def test_merge_adds_added_on_to_a_kaigis_entry_when_given
      kaigis = { "sample02" => { "name" => "sample02", "start_on" => "2027-01-01" } }
      added_on = { "sample02" => Date.new(2026, 5, 1) }

      result = Normalizer.merge(events: [], kaigis: kaigis, added_on: added_on)

      assert_equal Date.new(2026, 5, 1), result.first["added_on"]
    end

    def test_merge_leaves_added_on_unset_when_the_map_has_nothing_for_it
      kaigis = { "sample02" => { "name" => "sample02", "start_on" => "2027-01-01" } }

      result = Normalizer.merge(events: [], kaigis: kaigis)

      refute result.first.key?("added_on")
    end

    def test_merge_never_adds_added_on_to_a_legacy_events_entry
      events = [{ "name" => "legacy01", "start_on" => "2020-01-01" }]
      # Even a coincidentally-matching key in the map should not leak an
      # added_on onto an events.yml entry — only `kaigis` entries are
      # eligible (see the class comment on `merge`).
      added_on = { "legacy01" => Date.new(2020, 1, 1) }

      result = Normalizer.merge(events: events, kaigis: {}, added_on: added_on)

      refute result.first.key?("added_on")
    end

    def test_merge_breaks_same_start_on_ties_by_keeping_the_existing_order
      events = [
        { "name" => "nagoya02", "start_on" => "2011-02-26" },
        { "name" => "tochigi03", "start_on" => "2011-02-26" }
      ]

      result = Normalizer.merge(events: events, kaigis: {})

      assert_equal [1, 2], result.map { |event| event["seq"] }
    end
  end
end
