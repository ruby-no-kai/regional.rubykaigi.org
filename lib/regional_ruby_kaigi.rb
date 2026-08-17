# frozen_string_literal: true

require "date"
require_relative "regional_ruby_kaigi/normalizer"
require_relative "regional_ruby_kaigi/kaigi"

module RegionalRubyKaigi
  # The outermost namespace, never instantiated — module_function here (only
  # here; the classes nested under it stay classes) so a script can
  # `include RegionalRubyKaigi` and call `japan_today`/`upcoming` bare,
  # instead of qualifying every call. See script/generate_og_image.rb.
  module_function

  # Given a `site` (or anything with a `.data` Hash shaped like Jekyll's),
  # pulls out `events` and `kaigis` and merges them via Normalizer.
  # `_plugins/normalized_kaigi_generator.rb` is the only caller.
  def normalize_kaigis(site)
    Normalizer.merge(events: site.data["events"], kaigis: site.data["kaigis"])
  end

  # The kaigis that haven't happened yet as of `today`, earliest first, as
  # `Kaigi` objects. Which kaigi counts as upcoming — and fetching the list
  # to check — isn't Normalizer's job (that's about combining sources) or
  # the caller's (generate_og_image.rb): callers just want "what's
  # upcoming". `loader` only needs to respond to `.load`; override it in
  # tests instead of touching the filesystem.
  def upcoming(today = japan_today, loader: Normalizer)
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
