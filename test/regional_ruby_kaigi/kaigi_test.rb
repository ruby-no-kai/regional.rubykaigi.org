# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/regional_ruby_kaigi/kaigi"

module RegionalRubyKaigi
  class KaigiTest < Minitest::Test
    def test_title_reads_the_title_attribute
      kaigi = Kaigi.new("title" => "Sample Kaigi 01")

      assert_equal "Sample Kaigi 01", kaigi.title
    end

    def test_start_on_coerces_a_string_to_a_date
      kaigi = Kaigi.new("title" => "Sample", "start_on" => "2026-02-01")

      assert_equal Date.new(2026, 2, 1), kaigi.start_on
    end

    def test_start_on_accepts_a_date_already
      kaigi = Kaigi.new("title" => "Sample", "start_on" => Date.new(2026, 2, 1))

      assert_equal Date.new(2026, 2, 1), kaigi.start_on
    end

    def test_seq_reads_the_seq_attribute
      kaigi = Kaigi.new("title" => "Sample", "seq" => 42)

      assert_equal 42, kaigi.seq
    end
  end
end
