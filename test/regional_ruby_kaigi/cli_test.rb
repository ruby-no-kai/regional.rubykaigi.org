# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "tmpdir"
require_relative "../../lib/regional_ruby_kaigi/cli"

module RegionalRubyKaigi
  class CLITest < Minitest::Test
    def test_validate_kaigis_reports_success_for_valid_data
      fixture_dir = File.expand_path("../fixtures/data", __dir__)
      out = StringIO.new
      err = StringIO.new

      status = CLI.validate_kaigis(data_dir: fixture_dir, out: out, err: err)

      assert_equal 0, status
      assert_match(/件のイベントを検証しました/, out.string)
      assert_empty err.string
    end

    def test_validate_kaigis_reports_failure_for_invalid_data
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "- title: missing required fields\n")
        out = StringIO.new
        err = StringIO.new

        status = CLI.validate_kaigis(data_dir: dir, out: out, err: err)

        assert_equal 1, status
        assert_includes err.string, "name がありません"
      end
    end

    def test_validate_kaigis_reports_malformed_events_yml_via_normalizer
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "not an array\n")
        out = StringIO.new
        err = StringIO.new

        status = CLI.validate_kaigis(data_dir: dir, out: out, err: err)

        assert_equal 1, status
        assert_includes err.string, "最上位はイベントの配列にしてください"
      end
    end
  end
end
