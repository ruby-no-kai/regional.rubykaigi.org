#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "uri"
require "yaml"

module EventValidator
  DATA_FILE = File.expand_path("../_data/events.yml", __dir__)
  REQUIRED_FIELDS = %w[name title start_on end_on].freeze
  URL_FIELDS = %w[external_url report_url].freeze
  NAME_PATTERN = /\A[a-z0-9]+\z/
  DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

  module_function

  def normalized_date(value)
    return value if value.is_a?(Date)
    return unless value.is_a?(String) && DATE_PATTERN.match?(value)

    Date.iso8601(value)
  rescue Date::Error
    nil
  end

  def validate(events)
    return ["最上位はイベントの配列にしてください"] unless events.is_a?(Array)

    errors = []
    names = {}

    events.each_with_index do |event, index|
      location = "event ##{index + 1}"

      unless event.is_a?(Hash)
        errors << "#{location}: マッピングではありません"
        next
      end

      REQUIRED_FIELDS.each do |field|
        errors << "#{location}: #{field} がありません" if event[field].nil? || event[field].to_s.empty?
      end

      name = event["name"]
      if name
        errors << "#{location}: name は小文字英数字にしてください: #{name.inspect}" unless NAME_PATTERN.match?(name.to_s)
        if names.key?(name)
          errors << "#{location}: name #{name.inspect} は #{names[name]} と重複しています"
        else
          names[name] = location
        end
      end

      start_on = normalized_date(event["start_on"])
      end_on = normalized_date(event["end_on"])
      errors << "#{location}: start_on は YYYY-MM-DD 形式の日付にしてください" unless start_on
      errors << "#{location}: end_on は YYYY-MM-DD 形式の日付にしてください" unless end_on
      if start_on && end_on && start_on > end_on
        errors << "#{location}: end_on は start_on 以降にしてください"
      end

      URL_FIELDS.each do |field|
        value = event[field]
        next if value.nil?

        begin
          uri = URI.parse(value.to_s)
          errors << "#{location}: #{field} はHTTP(S) URLにしてください: #{value.inspect}" unless %w[http https].include?(uri.scheme) && uri.host
        rescue URI::InvalidURIError
          errors << "#{location}: #{field} が不正なURLです: #{value.inspect}"
        end
      end
    end

    errors
  end

  def run(data_file = DATA_FILE)
    events = YAML.safe_load_file(data_file, permitted_classes: [Date], aliases: false)
    unless events.is_a?(Array)
      warn "#{data_file}: 最上位はイベントの配列にしてください"
      return 1
    end

    errors = validate(events)

    if errors.empty?
      puts "#{events.length}件のイベントを検証しました"
      0
    else
      warn errors.join("\n")
      1
    end
  rescue Psych::Exception => e
    warn "#{data_file}: YAMLを読み込めません: #{e.message}"
    1
  end
end

exit EventValidator.run if $PROGRAM_NAME == __FILE__
