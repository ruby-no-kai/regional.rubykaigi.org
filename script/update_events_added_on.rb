# frozen_string_literal: true

# One-shot, run-by-hand script: finds `_data/events.yml` entries missing
# from `_data/events_added_on.yml` and appends their added_on date, derived
# by walking `git log -p` over `_data/events.yml` and finding the commit
# where `- name: <name>` first appears as an added line (git log is
# newest-first, so among several matches — an entry that got moved out to
# `_data/kaigis/` and back, say — the last one is the earliest).
#
# This can't be done cheaply at build time: `_data/events.yml`'s git
# history is one shared, ever-edited file, so finding one entry's added_on
# means walking the whole log — see _data/events_added_on.yml's own header,
# and RegionalRubyKaigi::Normalizer, for why entries missing from the cache
# fall back to their own start_on instead.
#
# Run after adding new `_data/events.yml` entries, review the diff, then
# commit `_data/events_added_on.yml` alongside them.

require "yaml"
require "date"
require "open3"

data_dir = File.expand_path("../_data", __dir__)
events_filepath = File.join(data_dir, "events.yml")
cache_filepath = File.join(data_dir, "events_added_on.yml")

events = YAML.safe_load_file(events_filepath, permitted_classes: [Date])
cache = YAML.safe_load_file(cache_filepath, permitted_classes: [Date]) || {}

# Older entries don't need this precision (Normalizer falls back to their
# own start_on) and walking the full git log to find one is expensive —
# restrict to entries close to today or in the future, the ones a reader
# might actually see as "recently added" in index.rss.
CUTOFF_YEAR = 2026
recent_events = events.select { |entry| entry["start_on"] && Date.parse(entry["start_on"].to_s).year >= CUTOFF_YEAR }
missing_names = recent_events.map { |entry| entry.fetch("name") } - cache.keys

if missing_names.empty?
  puts "events_added_on.yml already covers every events.yml entry"
  exit 0
end

out, status = Open3.capture2(
  "git", "-C", File.dirname(events_filepath),
  "log", "--follow", "--format=COMMIT %H %ad", "--date=short", "-p",
  "--", events_filepath
)
raise "git log failed" unless status.success?

# Earliest-added-line-wins per name: later matches (git log's newest-first
# order) keep overwriting earlier ones as the loop goes, so whichever
# commit is last to set added_on[name] is the oldest.
added_on = {}
current_commit_date = nil
out.each_line do |raw_line|
  line = raw_line.chomp
  if line.start_with?("COMMIT ")
    current_commit_date = line.split(" ", 3)[2]
  elsif (name = line[/\A\+- name: (.+)\z/, 1]) && missing_names.include?(name)
    added_on[name] = current_commit_date
  end
end

missing_names.each do |name|
  date = added_on[name]
  unless date
    warn "#{name}: no added line found in events.yml's git history, skipping"
    next
  end

  cache[name] = Date.parse(date)
  puts "#{name}: #{cache[name]}"
end

header = <<~HEADER
  # The date each `_data/events.yml` entry below (name => date) was first
  # added to git history — computed once by walking `git log -p` over
  # `_data/events.yml` and finding the commit where `- name: <name>` first
  # appears as an added line. Entries with a start_on in 2025 or earlier
  # don't need this precision (their held-on date is used instead); this
  # only needs to cover entries with a 2026-or-later start_on. Updated by
  # running script/update_events_added_on.rb by hand.
HEADER

body = cache.sort.to_h.to_yaml.sub(/\A---\n/, "")
File.write(cache_filepath, "---\n#{header}#{body}")
puts "Updated #{cache_filepath}"
