# frozen_string_literal: true

module RegionalRubyKaigi
  # `_data/events.yml` started as, and still is, a single ever-growing
  # array — an awkward file for an organizer to hand-edit a PR against.
  # New kaigis go into their own file under `_data/kaigis/` instead. This
  # combines both into the single flat Array of Hashes `_data/events.yml`
  # has always been — the shape Jekyll's templates read via
  # `site.data["events"]`, `Validator` checks entry by entry, and
  # `RegionalRubyKaigi.upcoming` filters and sorts. Each of those has its
  # own reason to want a flat Array; none of them need to be Jekyll to want
  # one.
  class Normalizer
    # The Jekyll-independent core: takes already-parsed Ruby data (matching
    # the shapes Jekyll::DataReader produces for `site.data`) and does no
    # I/O.
    def self.merge(...) = new.merge(...)

    def merge(events:, kaigis:)
      kaigis ||= {}
      normalized_kaigis = kaigis.map { |filename, entry| normalize(filename, entry) }
      # `events.yml` is already in `start_on` order (see event_filters.rb's
      # sort_events_by_start_on, which templates apply on top regardless —
      # this isn't the only place order matters, but it shouldn't be the
      # only place holding it up). The filename a kaigi happens to live in
      # says nothing about when it's held, so sort the appended kaigis the
      # same way: comparing as strings, not `Date`, keeps this from raising
      # on a `start_on` that's missing or malformed — Validator reports
      # that, not this.
      Array(events) + normalized_kaigis.sort_by { |entry| entry["start_on"].to_s }
    end

    private

    # An entry's `name` (an organizer-written field, optional and easy to
    # confuse with `filename` — the filename it came from, minus the
    # extension) is not required to match `filename`. Fall back to
    # `filename` when `name` is missing, so a missing field doesn't
    # silently become a validation gap. `held_on` is a single-day shorthand
    # organizers can write instead of `start_on`/`end_on`; expanded away
    # here so every other layer (Validator, templates, Kaigi, OgImage) only
    # ever deals in `start_on`/`end_on`.
    def normalize(filename, entry)
      entry = with_default_name(filename, entry) || entry
      with_expanded_held_on(entry) || entry
    end

    # Fills in `name` from `filename` when the entry doesn't have one;
    # returns `false` (not `nil`) when nothing needed filling in, so the
    # result composes with `||`.
    def with_default_name(filename, entry)
      entry["name"].to_s.empty? && entry.merge("name" => filename)
    end

    # Expands `held_on` into `start_on`/`end_on` both. When an entry gives
    # both `held_on` and `start_on`/`end_on`, `held_on` wins — silently
    # keeping a stale start_on/end_on would be worse than being opinionated
    # about precedence.
    def with_expanded_held_on(entry)
      return false unless entry.key?("held_on")

      held_on = entry["held_on"]
      entry.except("held_on").merge("start_on" => held_on, "end_on" => held_on)
    end
  end
end
