# frozen_string_literal: true

require_relative "../regional_ruby_kaigi"

module RegionalRubyKaigi
  # A single kaigi record, wrapping the raw Hash shape `_data/events.yml`
  # and `_data/kaigis/*.yml` produce, with typed accessors instead of
  # `fetch("...")` calls scattered through every caller. `start_on` is
  # always a `Date`, regardless of whether the underlying value came in as
  # a `Date` (parsed YAML) or a `String` (a test fixture literal).
  #
  # Accessors added one at a time as something needs them — not a
  # general-purpose model for every kaigi field. Normalizer, Validator, and
  # Jekyll's site.data["events"] still deal in plain Hashes; wrapping there
  # would be a bigger, separate decision.
  class Kaigi
    def initialize(attributes)
      @attributes = attributes
    end

    def title = @attributes.fetch("title")
    def start_on = RegionalRubyKaigi.date(@attributes.fetch("start_on"))

    # This kaigi's rank among every Regional RubyKaigi ever held, across
    # every region, in start_on order — 1 for the earliest. Set by
    # Normalizer#merge, not authored by hand (see its comment for why).
    def seq = @attributes.fetch("seq")
  end
end
