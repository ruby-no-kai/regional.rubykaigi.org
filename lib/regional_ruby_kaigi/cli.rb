# frozen_string_literal: true

require_relative "normalizer"
require_relative "validator"

module RegionalRubyKaigi
  # The CLI-facing entry points invoked from script/*.rb. Each one owns I/O
  # (stdout/stderr, the process exit code) and orchestrates the pure lib
  # classes (Normalizer, Validator, ...) to do it, so script/*.rb itself
  # stays a one-line adapter. New CLI operations get a new class method
  # here rather than a new script/*.rb full of logic.
  class CLI
    def self.validate_kaigis(...) = new(...).validate_kaigis

    def initialize(data_dir: nil, out: $stdout, err: $stderr)
      @data_dir = data_dir
      @out = out
      @err = err
    end

    def validate_kaigis
      kaigis = Normalizer.load(data_dir: @data_dir)
      errors = Validator.validate(kaigis)

      if errors.empty?
        @out.puts "#{kaigis.length}件のイベントを検証しました"
        0
      else
        @err.puts errors.join("\n")
        1
      end
    rescue Normalizer::InvalidData => e
      @err.puts e.message
      1
    end
  end
end
