# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/generate_og_image"

class GenerateOgImageTest < Minitest::Test
  def test_selects_upcoming_events_in_date_order
    events = [
      { "title" => "Past", "start_on" => Date.new(2026, 1, 1) },
      { "title" => "Later", "start_on" => "2026-03-01" },
      { "title" => "Today", "start_on" => Date.new(2026, 2, 1) }
    ]

    upcoming = OgImageGenerator.upcoming_events(events, today: Date.new(2026, 2, 1))

    assert_equal %w[Today Later], upcoming.map { |event| event.fetch("title") }
  end

  def test_returns_nil_when_there_are_no_upcoming_events
    events = [{ "title" => "Past", "start_on" => Date.new(2026, 1, 1) }]

    assert_empty OgImageGenerator.upcoming_events(events, today: Date.new(2026, 2, 1))
  end

  def test_uses_japan_date_at_the_utc_date_boundary
    now = Time.new(2026, 2, 1, 15, 30, 0, "+00:00")

    assert_equal Date.new(2026, 2, 2), OgImageGenerator.japan_today(now)
  end

  def test_escapes_event_titles_in_svg
    svg = OgImageGenerator.render_svg([{ "title" => "Ruby & Friends", "start_on" => Date.new(2026, 2, 1) }])

    assert_includes svg, "Ruby &amp; Friends"
  end

  def test_limits_visible_events_and_reports_the_remaining_count
    events = 7.times.map do |index|
      { "title" => "Event #{index}", "start_on" => Date.new(2026, 2, index + 1) }
    end

    svg = OgImageGenerator.render_svg(events)

    assert_includes svg, "Event 4"
    refute_includes svg, "Event 5"
    assert_includes svg, "ほか2件"
    assert_equal OgImageGenerator::MAX_EVENTS, svg.scan("<circle ").length
  end

  def test_renders_a_fallback_when_there_are_no_upcoming_events
    svg = OgImageGenerator.render_svg([])

    assert_includes svg, "次回の開催をお楽しみに"
    assert_includes svg, "開催予定はまだありません"
  end
end
