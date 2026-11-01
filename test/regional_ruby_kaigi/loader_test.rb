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

    def test_added_on_by_filename_returns_each_requested_filenames_first_commit_date
      result = Loader.added_on_by_filename(%w[sample02], data_dir: FIXTURE_DIR)

      assert_equal({ "sample02" => Date.new(2026, 8, 17) }, result)
    end

    def test_added_on_by_filename_omits_a_filename_not_found_under_kaigis
      result = Loader.added_on_by_filename(%w[nonexistent], data_dir: FIXTURE_DIR)

      assert_empty result
    end

    def test_events_added_on_returns_the_map_from_events_added_on_yml
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "events_added_on.yml"), "legacy01: 2020-03-15\n")

        result = Loader.new(data_dir: dir).events_added_on

        assert_equal({ "legacy01" => Date.new(2020, 3, 15) }, result)
      end
    end

    def test_events_added_on_returns_empty_when_the_file_is_missing
      Dir.mktmpdir do |dir|
        assert_empty Loader.new(data_dir: dir).events_added_on
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
