# frozen_string_literal: true

require "date"
require "uri"

module EventFilters
  def sort_events_by_start_on(events)
    Array(events).sort_by do |event|
      Date.iso8601(event.fetch("start_on").to_s)
    end
  end

  def external_to_regional_rubykaigi(url)
    host = URI.parse(url.to_s).host
    !host.nil? && host != "regional.rubykaigi.org"
  rescue URI::InvalidURIError
    false
  end

  # An event's canonical, absolute URL: its own external_url when it has
  # one, otherwise its page under regional.rubykaigi.org. index.html
  # computes this inline instead (it only ever needs a path, resolved
  # relative to the page it's already on); index.rss needs an absolute URL
  # regardless of source, since a feed reader has no "current page" to
  # resolve a relative one against.
  def event_url(event)
    external_url = event["external_url"]
    return external_url unless external_url.to_s.empty?

    "https://regional.rubykaigi.org/#{event.fetch("name")}/"
  end

  # The `limit` most recently *added* events — not most recently *held*
  # ones (that's sort_events_by_start_on) — for index.rss. Only events
  # with an added_on survive at all; that's every _data/kaigis/ entry and
  # none of _data/events.yml's (see GitAddedOn and Normalizer for why).
  def recent_events(events, limit)
    Array(events)
      .select { |event| event["added_on"] }
      .sort_by { |event| Date.iso8601(event.fetch("added_on").to_s) }
      .reverse
      .first(limit.to_i)
  end
end

Liquid::Template.register_filter(EventFilters)
