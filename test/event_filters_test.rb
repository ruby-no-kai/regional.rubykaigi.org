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

  def test_event_url_prefers_the_external_url
    event = { "name" => "example01", "external_url" => "https://example.org/" }

    assert_equal "https://example.org/", event_url(event)
  end

  def test_event_url_falls_back_to_an_absolute_regional_rubykaigi_path
    event = { "name" => "example01" }

    assert_equal "https://regional.rubykaigi.org/example01/", event_url(event)
  end

  def test_recent_events_sorts_by_added_on_descending
    events = [
      { "name" => "older", "added_on" => "2026-01-01" },
      { "name" => "newer", "added_on" => Date.new(2026, 3, 1) }
    ]

    assert_equal %w[newer older], recent_events(events, 10).map { |event| event["name"] }
  end

  def test_recent_events_excludes_entries_without_added_on
    events = [
      { "name" => "no_added_on" },
      { "name" => "has_added_on", "added_on" => "2026-01-01" }
    ]

    assert_equal %w[has_added_on], recent_events(events, 10).map { |event| event["name"] }
  end

  def test_recent_events_caps_at_the_limit
    events = (1..5).map { |i| { "name" => "e#{i}", "added_on" => "2026-01-0#{i}" } }

    assert_equal 3, recent_events(events, 3).length
  end
end
