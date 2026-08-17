# frozen_string_literal: true

require "date"
require "uri"

module RegionalRubyKaigi
  # Checks a kaigi list against the rules CONTRIBUTING.md documents:
  # required fields, a name that's unique and lowercase alnum, dates in
  # order, and URLs that look like URLs. Pure — no I/O, no knowledge of
  # where the kaigi list came from.
  class Validator
    REQUIRED_FIELDS = %w[name title start_on end_on].freeze
    URL_FIELDS = %w[external_url report_url].freeze
    NAME_PATTERN = /\A[a-z0-9]+\z/
    DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

    def self.validate(...) = new.validate(...)

    def validate(kaigis)
      return ["最上位はイベントの配列にしてください"] unless kaigis.is_a?(Array)

      errors = []
      names = {}

      kaigis.each_with_index do |kaigi, index|
        location = "event ##{index + 1}"

        unless kaigi.is_a?(Hash)
          errors << "#{location}: マッピングではありません"
          next
        end

        REQUIRED_FIELDS.each do |field|
          errors << "#{location}: #{field} がありません" if kaigi[field].nil? || kaigi[field].to_s.empty?
        end

        name = kaigi["name"]
        if name
          errors << "#{location}: name は小文字英数字にしてください: #{name.inspect}" unless NAME_PATTERN.match?(name.to_s)
          if names.key?(name)
            errors << "#{location}: name #{name.inspect} は #{names[name]} と重複しています"
          else
            names[name] = location
          end
        end

        start_on = normalized_date(kaigi["start_on"])
        end_on = normalized_date(kaigi["end_on"])
        errors << "#{location}: start_on は YYYY-MM-DD 形式の日付にしてください" unless start_on
        errors << "#{location}: end_on は YYYY-MM-DD 形式の日付にしてください" unless end_on
        if start_on && end_on && start_on > end_on
          errors << "#{location}: end_on は start_on 以降にしてください"
        end

        URL_FIELDS.each do |field|
          value = kaigi[field]
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

    private

    def normalized_date(value)
      return value if value.is_a?(Date)
      return unless value.is_a?(String) && DATE_PATTERN.match?(value)

      Date.iso8601(value)
    rescue Date::Error
      nil
    end
  end
end
