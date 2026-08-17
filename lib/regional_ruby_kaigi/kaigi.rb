# frozen_string_literal: true

require_relative "../regional_ruby_kaigi"

module RegionalRubyKaigi
  # A single kaigi record, wrapping the raw Hash shape `_data/events.yml`
  # and `_data/kaigis/*.yml` produce, with typed accessors instead of
  # `fetch("...")` calls scattered through every caller. `start_on` is
  # always a `Date`, regardless of whether the underlying value came in as
  # a `Date` (parsed YAML) or a `String` (a test fixture literal).
  #
  # Scoped to what OgImage's rendering needs today — not a general-purpose
  # model for every kaigi field. Normalizer, Validator, and Jekyll's
  # site.data["events"] still deal in plain Hashes; wrapping there would be
  # a bigger, separate decision.
  class Kaigi
    def initialize(attributes)
      @attributes = attributes
    end

    def title = @attributes.fetch("title")
    def start_on = RegionalRubyKaigi.date(@attributes.fetch("start_on"))
  end
end
