# frozen_string_literal: true

require "date"

module EventFilters
  def sort_events_by_start_on(events)
    Array(events).sort_by do |event|
      Date.iso8601(event.fetch("start_on").to_s)
    end
  end
end

Liquid::Template.register_filter(EventFilters)
