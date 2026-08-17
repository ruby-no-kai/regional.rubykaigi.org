# frozen_string_literal: true

require "date"
require "yaml"

module RegionalRubyKaigi
  # `_data/events.yml` started as, and still is, a single ever-growing
  # array — an awkward file for an organizer to hand-edit a PR against.
  # New kaigis go into their own file under `_data/kaigis/` instead. This
  # combines both into the single flat array templates, the validator, and
  # the OG image generator have always expected `site.data.events` to be.
  class Normalizer
    # Raised when the on-disk data can't be turned into a kaigi list: a
    # malformed `events.yml` (not a YAML array at the top level) or YAML
    # that fails to parse.
    class InvalidData < StandardError; end

    DEFAULT_DATA_DIR = File.expand_path("../../_data", __dir__)
    private_constant :DEFAULT_DATA_DIR

    # The Jekyll-independent core: takes already-parsed Ruby data (matching
    # the shapes Jekyll::DataReader produces for `site.data`) and does no
    # I/O.
    def self.merge(...) = new.merge(...)

    # The filesystem entry point for callers that run outside Jekyll
    # (validate_events.rb, generate_og_image.rb, tests): reads the same
    # files `_data/events.yml` and `_data/kaigis/*.yml` from disk and calls
    # `.merge`. Callers should not need to know the data directory layout
    # beyond that — pass `data_dir` only to override it (fixtures, tests);
    # the default lives here, not duplicated in every caller.
    def self.load(data_dir: nil) = new(data_dir: data_dir).load

    def initialize(data_dir: nil)
      @data_dir = data_dir || DEFAULT_DATA_DIR
    end

    def merge(events:, kaigis:)
      kaigis ||= {}
      Array(events) + kaigis.keys.sort.map { |key| normalize(kaigis[key], key) }
    end

    def load
      events_file = File.join(@data_dir, "events.yml")
      events = read_yaml_file(events_file) || []
      raise InvalidData, "#{events_file}: 最上位はイベントの配列にしてください" unless events.is_a?(Array)

      kaigis = Dir.glob(File.join(@data_dir, "kaigis", "*.{yml,yaml}")).each_with_object({}) do |path, hash|
        key = File.basename(path, ".*")
        hash[key] = read_yaml_file(path)
      end

      merge(events: events, kaigis: kaigis)
    rescue Psych::Exception => e
      raise InvalidData, "#{@data_dir}: YAMLを読み込めません: #{e.message}"
    end

    private

    # An entry's `name` is not required to match its filename — fall back to
    # `key` when it's missing, so a missing field doesn't silently become a
    # validation gap.
    def normalize(entry, key)
      with_default_name(entry, key) || entry
    end

    # Fills in `name` from `key` when the entry doesn't have one; returns
    # `false` (not `nil`) so `normalize` can compose it with `||` above.
    def with_default_name(entry, key)
      entry["name"].to_s.empty? && entry.merge("name" => key)
    end

    def read_yaml_file(path) = YAML.safe_load_file(path, permitted_classes: [Date], aliases: false)
  end
end
