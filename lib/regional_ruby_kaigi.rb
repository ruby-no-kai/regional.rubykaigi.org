# frozen_string_literal: true

require "date"
require_relative "regional_ruby_kaigi/normalizer"
require_relative "regional_ruby_kaigi/loader"
require_relative "regional_ruby_kaigi/kaigi"
require_relative "regional_ruby_kaigi/validator"

module RegionalRubyKaigi
  # The outermost namespace, never instantiated — module_function here (only
  # here; the classes nested under it stay classes) so a script can
  # `include RegionalRubyKaigi` and call `japan_today`/`upcoming` bare,
  # instead of qualifying every call. See script/generate_og_image.rb.
  module_function

  # Raised by `validate_kaigis!` when the kaigi data isn't valid. `errors`
  # holds every message collected — filename/name mismatches, missing or
  # malformed fields — not just the first one, so a caller can report all
  # of them in one pass.
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("#{errors.length}件のエラーがあります")
    end
  end

  # The processing NormalizedKaigiGenerator needs: given a `site` (or
  # anything with a `.data` Hash shaped like Jekyll's), pulls out `events`
  # and `kaigis`, asks `loader` for each kaigi's added_on date plus the
  # hand-worked-out ones for events.yml entries, and merges everything via
  # Normalizer. Returns a plain Array of Hashes — the shape
  # `site.data["events"]` is assigned back to. `site` is the only Jekyll
  # knowledge in this call — `loader` (Loader by default; a test can pass a
  # stub) never sees `site` itself, only the plain filename Strings pulled
  # out of it.
  def normalize_kaigis(site, loader: Loader)
    kaigis = site.data["kaigis"]
    added_on = loader.added_on_by_filename((kaigis || {}).keys)
    Normalizer.merge(events: site.data["events"], kaigis: kaigis, added_on: added_on, events_added_on: loader.events_added_on)
  end

  # What "validate the kaigi data" means: read it, and check both the
  # filename/name agreement only Loader can see and the field-level rules
  # only Validator knows. A caller that wants this (CLI) shouldn't need to
  # know it's two collaborators combined this particular way. Returns the
  # kaigis when they're valid; raises ValidationError (carrying every
  # message collected) otherwise — the `!` says a caller can treat getting
  # a return value at all as "valid," instead of checking an errors list.
  def validate_kaigis!(data_dir: nil)
    kaigis = Loader.load(data_dir: data_dir)
    errors = Loader.name_mismatches(data_dir: data_dir) + Validator.validate(kaigis)
    raise ValidationError, errors unless errors.empty?

    kaigis
  end

  # The kaigis that haven't happened yet as of `today`, earliest first, as
  # `Kaigi` objects. Which kaigi counts as upcoming — and fetching the list
  # to check — isn't Loader's job (that's about reading and combining
  # sources) or the caller's (generate_og_image.rb): callers just want
  # "what's upcoming". `loader` only needs to respond to `.load`; override
  # it in tests instead of touching the filesystem.
  def upcoming(today = japan_today, loader: Loader)
    loader.load
      .map { |attrs| Kaigi.new(attrs) }
      .select { |kaigi| kaigi.start_on >= today }
      .sort_by(&:start_on)
  end

  def japan_today(now = Time.now) = now.getlocal("+09:00").to_date

  # Coerces a kaigi's `start_on`/`end_on` value — a `Date` already if it
  # came through Jekyll's or Psych's YAML parsing, a `String` if it came from
  # a test fixture literal — into a `Date`. `Kaigi` uses this; anything else
  # touching a raw kaigi Hash's dates should too, rather than reimplementing
  # the coercion. Not `to_date`: this converts its argument, not `self` — the
  # `to_*` family is for receiver conversions (`"...".to_date`,
  # `time.to_date` below), and calling this that way would say the opposite
  # of what it does.
  def date(value) = Date.iso8601(value.to_s)
end
