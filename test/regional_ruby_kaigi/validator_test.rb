# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/regional_ruby_kaigi/validator"

module RegionalRubyKaigi
  class ValidatorTest < Minitest::Test
    def valid_kaigi(overrides = {})
      {
        "name" => "tokyo01",
        "title" => "Tokyo RubyKaigi 01",
        "start_on" => "2026-01-10",
        "end_on" => "2026-01-11",
        "external_url" => "https://example.com/event",
        "report_url" => "http://example.com/report"
      }.merge(overrides)
    end

    def test_accepts_a_valid_kaigi
      assert_empty Validator.validate([valid_kaigi])
    end

    def test_requires_an_array_at_the_top_level
      assert_equal ["最上位はイベントの配列にしてください"], Validator.validate({})
    end

    def test_requires_a_mapping_and_required_fields
      errors = Validator.validate(["event", {}])

      assert_includes errors, "event #1: マッピングではありません"
      %w[name title start_on end_on].each do |field|
        assert_includes errors, "event #2: #{field} がありません"
      end
    end

    def test_validates_name_and_duplicate_names
      kaigis = [valid_kaigi("name" => "Tokyo-01"), valid_kaigi("name" => "Tokyo-01")]
      errors = Validator.validate(kaigis)

      assert_includes errors, 'event #1: name は小文字英数字にしてください: "Tokyo-01"'
      assert_includes errors, 'event #2: name "Tokyo-01" は event #1 と重複しています'
    end

    def test_validates_dates_and_their_order
      invalid_dates = Validator.validate([valid_kaigi("start_on" => "2026-02-30", "end_on" => "01-01-2026")])
      reversed_dates = Validator.validate([valid_kaigi("start_on" => "2026-01-11", "end_on" => "2026-01-10")])

      assert_includes invalid_dates, "event #1: start_on は YYYY-MM-DD 形式の日付にしてください"
      assert_includes invalid_dates, "event #1: end_on は YYYY-MM-DD 形式の日付にしてください"
      assert_includes reversed_dates, "event #1: end_on は start_on 以降にしてください"
    end

    def test_accepts_yaml_date_objects
      kaigi = valid_kaigi("start_on" => Date.new(2026, 1, 10), "end_on" => Date.new(2026, 1, 11))

      assert_empty Validator.validate([kaigi])
    end

    def test_validates_urls
      errors = Validator.validate([valid_kaigi("external_url" => "ftp://example.com", "report_url" => "https://exa mple.com")])

      assert_includes errors, 'event #1: external_url はHTTP(S) URLにしてください: "ftp://example.com"'
      assert_includes errors, 'event #1: report_url が不正なURLです: "https://exa mple.com"'
    end
  end
end
