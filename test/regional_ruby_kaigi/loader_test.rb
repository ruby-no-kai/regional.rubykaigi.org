# frozen_string_literal: true

require "date"
require "minitest/autorun"
require "tmpdir"
require_relative "../../lib/regional_ruby_kaigi/loader"

module RegionalRubyKaigi
  class LoaderTest < Minitest::Test
    FIXTURE_DIR = File.expand_path("../fixtures/data", __dir__)

    def test_load_reads_events_yml_and_kaigis_from_disk
      result = Loader.load(data_dir: FIXTURE_DIR)

      assert_equal %w[legacy01 noname03 sample02], result.map { |event| event["name"] }.sort
      sample = result.find { |event| event["name"] == "sample02" }
      assert_equal Date.new(2021, 2, 2), sample["start_on"]
    end

    def test_load_defaults_to_the_repository_data_directory
      result = Loader.load

      assert(result.any? { |event| event["name"] == "tokyo01" })
    end

    def test_load_raises_invalid_data_when_events_yml_is_not_an_array
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "name: not-an-array\n")

        error = assert_raises(Loader::InvalidData) do
          Loader.load(data_dir: dir)
        end
        assert_includes error.message, "最上位はイベントの配列にしてください"
      end
    end

    def test_load_raises_invalid_data_on_malformed_yaml
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "- name: [unterminated\n")

        assert_raises(Loader::InvalidData) do
          Loader.load(data_dir: dir)
        end
      end
    end

    def test_name_mismatches_is_empty_for_fixture_data
      assert_empty Loader.name_mismatches(data_dir: FIXTURE_DIR)
    end

    def test_name_mismatches_flags_a_name_that_does_not_match_its_filename
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "[]\n")
        Dir.mkdir(File.join(dir, "kaigis"))
        File.write(File.join(dir, "kaigis", "okrk03.yml"), "name: okrk04\ntitle: Oops\n")

        mismatches = Loader.name_mismatches(data_dir: dir)

        assert_equal 1, mismatches.length
        assert_match(/okrk03\.yml/, mismatches.first)
        assert_match(/"okrk04"/, mismatches.first)
      end
    end

    def test_name_mismatches_allows_a_missing_name
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events.yml"), "[]\n")
        Dir.mkdir(File.join(dir, "kaigis"))
        File.write(File.join(dir, "kaigis", "noname05.yml"), "title: No Name\n")

        assert_empty Loader.name_mismatches(data_dir: dir)
      end
    end
  end
end
