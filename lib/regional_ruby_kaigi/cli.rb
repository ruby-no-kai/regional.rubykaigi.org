# frozen_string_literal: true

require_relative "../regional_ruby_kaigi"

module RegionalRubyKaigi
  # The CLI-facing entry points invoked from script/*.rb. Each one owns I/O
  # (stdout/stderr, the process exit code) and asks RegionalRubyKaigi to do
  # the actual work, so script/*.rb itself stays a one-line adapter. New
  # CLI operations get a new class method here rather than a new
  # script/*.rb full of logic.
  class CLI
    def self.validate_kaigis(...) = new(...).validate_kaigis

    def initialize(data_dir: nil, out: $stdout, err: $stderr)
      @data_dir = data_dir
      @out = out
      @err = err
    end

    def validate_kaigis
      kaigis = RegionalRubyKaigi.validate_kaigis!(data_dir: @data_dir)
      @out.puts "#{kaigis.length}件のイベントを検証しました"
      0
    rescue RegionalRubyKaigi::ValidationError => e
      @err.puts e.errors.join("\n")
      1
    rescue Loader::InvalidData => e
      @err.puts e.message
      1
    end
  end
end
