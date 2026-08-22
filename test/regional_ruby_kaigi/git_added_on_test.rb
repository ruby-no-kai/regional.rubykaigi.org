# frozen_string_literal: true

require "date"
require "minitest/autorun"
require "tmpdir"
require_relative "../../lib/regional_ruby_kaigi/git_added_on"

module RegionalRubyKaigi
  class GitAddedOnTest < Minitest::Test
    def test_for_returns_the_date_the_file_was_first_committed
      Dir.mktmpdir do |dir|
        init_repo(dir)
        filepath = write_and_commit(dir, "sample.yml", "title: Sample\n", on: "2021-05-06T00:00:00")

        assert_equal Date.new(2021, 5, 6), GitAddedOn.for(filepath)
      end
    end

    def test_for_returns_the_earliest_add_even_after_later_edits
      Dir.mktmpdir do |dir|
        init_repo(dir)
        filepath = write_and_commit(dir, "sample.yml", "title: Sample\n", on: "2021-05-06T00:00:00")
        write_and_commit(dir, "sample.yml", "title: Sample Updated\n", on: "2022-01-01T00:00:00")

        assert_equal Date.new(2021, 5, 6), GitAddedOn.for(filepath)
      end
    end

    def test_for_returns_nil_for_a_file_that_has_never_been_committed
      Dir.mktmpdir do |dir|
        init_repo(dir)
        filepath = File.join(dir, "untracked.yml")
        File.write(filepath, "title: Untracked\n")

        assert_nil GitAddedOn.for(filepath)
      end
    end

    def test_for_returns_nil_when_the_directory_is_not_a_git_repository
      Dir.mktmpdir do |dir|
        filepath = File.join(dir, "not-a-repo.yml")
        File.write(filepath, "title: Not A Repo\n")

        assert_nil GitAddedOn.for(filepath)
      end
    end

    private

    def init_repo(dir)
      run_git(dir, "init", "-q", "-b", "main")
      run_git(dir, "config", "user.email", "test@example.com")
      run_git(dir, "config", "user.name", "Test")
    end

    def write_and_commit(dir, filename, content, on:)
      filepath = File.join(dir, filename)
      File.write(filepath, content)
      run_git(dir, "add", filename)
      run_git(dir, "commit", "-q", "-m", "commit", env: { "GIT_AUTHOR_DATE" => on, "GIT_COMMITTER_DATE" => on })
      filepath
    end

    def run_git(dir, *args, env: {})
      result = system(env, "git", "-C", dir, *args, out: File::NULL, err: File::NULL)
      raise "git #{args.join(' ')} failed" unless result
    end
  end
end
