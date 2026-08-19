# frozen_string_literal: true

require "date"
require "yaml"
require_relative "normalizer"

module RegionalRubyKaigi
  # Reads `_data/events.yml` and `_data/kaigis/*.yml` from disk and hands
  # the result to Normalizer to combine into the single flat Array every
  # consumer works with (see Normalizer for why that shape). Jekyll isn't
  # involved here — this reads the same way whether or not Jekyll is even
  # running.
  class Loader
    # Raised when the on-disk data can't be turned into a kaigi list: a
    # malformed `events.yml` (not a YAML array at the top level) or YAML
    # that fails to parse.
    class InvalidData < StandardError; end

    DEFAULT_DATA_DIR = File.expand_path("../../_data", __dir__)
    private_constant :DEFAULT_DATA_DIR

    def self.load(data_dir: nil) = new(data_dir: data_dir).load

    # An entry's `name` doesn't have to match its `filename` — `load` fills
    # it in from `filename` when it's missing — but when an organizer does
    # write one, a mismatch is almost certainly a mistake (a copy-paste left
    # over from another kaigi's file, a typo). `Validator` can't catch this:
    # by the time a kaigi list reaches it, the entries are a flat array with
    # no memory of which file they came from. Only something that reads
    # `_data/kaigis/` itself — this — can compare the two.
    def self.name_mismatches(data_dir: nil) = new(data_dir: data_dir).name_mismatches

    def initialize(data_dir: nil)
      @data_dir = data_dir || DEFAULT_DATA_DIR
    end

    def load
      events_filepath = File.join(@data_dir, "events.yml")
      events = read_yaml_file(events_filepath) || []
      raise InvalidData, "#{events_filepath}: 最上位はイベントの配列にしてください" unless events.is_a?(Array)

      kaigis = kaigi_files.each_with_object({}) { |file, hash| hash[file[:filename]] = file[:entry] }

      Normalizer.merge(events: events, kaigis: kaigis)
    rescue Psych::Exception => e
      raise InvalidData, "#{@data_dir}: YAMLを読み込めません: #{e.message}"
    end

    def name_mismatches
      kaigi_files.filter_map do |file|
        entry_name = file[:entry]["name"]
        next if entry_name_matches_filename?(entry_name, file[:filename])

        "#{file[:filepath]}: name #{entry_name.inspect} はファイル名と一致していません（#{file[:filename].inspect} を期待）"
      end
    rescue Psych::Exception => e
      raise InvalidData, "#{@data_dir}: YAMLを読み込めません: #{e.message}"
    end

    private

    # A missing `entry_name` isn't a mismatch — `load` will fill it in from
    # `filename` — only one that disagrees with `filename` is.
    def entry_name_matches_filename?(entry_name, filename)
      entry_name.to_s.empty? || entry_name == filename
    end

    # Every file under `_data/kaigis/`, as `{filepath:, filename:, entry:}`.
    def kaigi_files
      Dir.glob(File.join(@data_dir, "kaigis", "*.{yml,yaml}")).map do |filepath|
        { filepath: filepath, filename: File.basename(filepath, ".*"), entry: read_yaml_file(filepath) }
      end
    end

    def read_yaml_file(filepath)
      YAML.safe_load_file(filepath, permitted_classes: [Date], aliases: false)
    end
  end
end
