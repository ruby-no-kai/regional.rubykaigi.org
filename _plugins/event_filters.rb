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
end

Liquid::Template.register_filter(EventFilters)
