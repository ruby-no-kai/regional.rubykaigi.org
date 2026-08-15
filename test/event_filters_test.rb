# frozen_string_literal: true

require "minitest/autorun"
require "liquid"
require_relative "../_plugins/event_filters"

class EventFiltersTest < Minitest::Test
  include EventFilters

  def test_sorts_events_by_start_on_regardless_of_input_order
    events = [
      { "name" => "later", "start_on" => "2026-02-01" },
      { "name" => "earlier", "start_on" => Date.new(2026, 1, 1) }
    ]

    assert_equal %w[earlier later], sort_events_by_start_on(events).map { |event| event["name"] }
  end

  def test_does_not_mutate_the_input
    events = [
      { "name" => "later", "start_on" => "2026-02-01" },
      { "name" => "earlier", "start_on" => "2026-01-01" }
    ]

    sort_events_by_start_on(events)

    assert_equal %w[later earlier], events.map { |event| event["name"] }
  end

  def test_regional_rubykaigi_url_stays_in_the_same_tab
    refute external_to_regional_rubykaigi("https://regional.rubykaigi.org/nagara01/")
  end

  def test_other_domains_open_in_a_new_tab
    assert external_to_regional_rubykaigi("https://tokyurubykaigi.github.io/tokyu16/")
  end

  def test_relative_urls_stay_in_the_same_tab
    refute external_to_regional_rubykaigi("/izumo01/")
  end
end
