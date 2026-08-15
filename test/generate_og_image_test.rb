# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/generate_og_image"

class GenerateOgImageTest < Minitest::Test
  def test_selects_the_nearest_upcoming_event
    events = [
      { "title" => "Past", "start_on" => Date.new(2026, 1, 1) },
      { "title" => "Later", "start_on" => "2026-03-01" },
      { "title" => "Today", "start_on" => Date.new(2026, 2, 1) }
    ]

    event = OgImageGenerator.upcoming_event(events, today: Date.new(2026, 2, 1))

    assert_equal "Today", event.fetch("title")
  end

  def test_returns_nil_when_there_are_no_upcoming_events
    events = [{ "title" => "Past", "start_on" => Date.new(2026, 1, 1) }]

    assert_nil OgImageGenerator.upcoming_event(events, today: Date.new(2026, 2, 1))
  end

  def test_uses_japan_date_at_the_utc_date_boundary
    now = Time.new(2026, 2, 1, 15, 30, 0, "+00:00")

    assert_equal Date.new(2026, 2, 2), OgImageGenerator.japan_today(now)
  end

  def test_escapes_event_titles_in_svg
    svg = OgImageGenerator.render_svg("title" => "Ruby & Friends", "start_on" => Date.new(2026, 2, 1))

    assert_includes svg, "Ruby &amp; Friends"
  end
end
