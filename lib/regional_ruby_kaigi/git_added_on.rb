# frozen_string_literal: true

require "date"
require "open3"

module RegionalRubyKaigi
  # The date `filepath` was first added to git history — not something an
  # organizer writes (CONTRIBUTING.md has no such field), but derived from
  # when its file entered the repository. Meaningful only for the
  # one-file-per-kaigi entries under `_data/kaigis/`; `_data/events.yml`
  # bundles every legacy kaigi into a single shared file, so per-entry git
  # history there reflects that file's own edit history (bulk imports,
  # reordering) rather than any one kaigi's — callers should not call this
  # for entries sourced from there.
  #
  # `--follow` tracks the file across renames; `--diff-filter=A` keeps only
  # the commits that introduced it, not later edits; the oldest such commit
  # — last in git's newest-first log — is the one that matters.
  class GitAddedOn
    def self.for(filepath) = new.for(filepath)

    def for(filepath)
      # A file with no history yet (untracked, or a repo with no commits)
      # is an expected, handled case here, not a real error — send git's
      # own "fatal: ..." commentary about it to the void instead of
      # spilling into a caller's build/test output.
      out, status = Open3.capture2(
        "git", "-C", File.dirname(filepath),
        "log", "--follow", "--diff-filter=A", "--format=%ad", "--date=short",
        "--", filepath,
        err: File::NULL
      )
      return nil unless status.success?

      added_on = out.lines.map(&:strip).reject(&:empty?).last
      added_on && Date.iso8601(added_on)
    rescue Errno::ENOENT
      # git itself isn't installed/on PATH — fall back to no added_on
      # rather than failing the whole site build over it.
      nil
    end
  end
end
