# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "tmpdir"
require_relative "../lib/regional_ruby_kaigi/loader"

class IndexRenderingTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def self.rendered_html
    @rendered_html ||= Dir.mktmpdir("regional-rubykaigi-site") do |destination|
      # Load gems from the Gemfile's :jekyll_plugins group first, exactly as
      # `exe/jekyll` does before building a site. Skipping this would build
      # against a different plugin/safe-mode configuration than `bundle exec
      # jekyll build` (what CI and deploy.yml actually run) — see
      # .agents/notes/track2-data-integration-infra.md for the production bug
      # this blind spot hid (the `github-pages` gem, merely by being present
      # in that Bundler group, used to force safe mode and silently disable
      # everything under `_plugins/`).
      Dir.chdir(ROOT) { Jekyll::PluginManager.require_from_bundler }

      config = Jekyll.configuration(
        "source" => ROOT,
        "destination" => destination,
        "quiet" => true
      )
      Jekyll::Site.new(config).process
      File.read(File.join(destination, "index.html"))
    end
  end

  def setup
    @html = self.class.rendered_html
  end

  def test_regional_rubykaigi_event_stays_in_the_same_tab
    anchor = event_anchor("https://regional.rubykaigi.org/nagara01/")

    refute_includes anchor, 'target="_blank"'
    assert_includes anchor, "external-icon"
  end

  def test_off_site_event_opens_in_a_new_tab
    anchor = event_anchor("https://tokyurubykaigi.github.io/tokyu16/")

    assert_includes anchor, 'target="_blank"'
    assert_includes anchor, 'rel="noopener"'
    assert_includes anchor, "external-icon"
  end

  def test_internal_event_stays_in_the_same_tab
    anchor = event_anchor("/izumo01/")

    refute_includes anchor, 'target="_blank"'
    assert_includes anchor, "external-icon"
  end

  def test_includes_explicit_x_card_metadata
    assert_includes @html, '<meta name="twitter:card" content="summary_large_image">'
    assert_match %r{<meta name="twitter:image" content="https://regional\.rubykaigi\.org/images/og/regional-rubykaigi\.png\?v=(?:latest|[0-9a-f]{12})">}, @html
  end

  # The three ways the rendered page counts events — the "これまでの開催"
  # heading's past_count, one .upcoming-card per upcoming event, and one
  # event-seq value per event — are computed independently (Liquid
  # counters vs. Normalizer's seq), so nothing but a real build catches
  # them drifting apart. All three should add up to the same total as
  # Loader.load against the real _data/ directory, and seq should cover
  # 1..total with no gaps or duplicates.
  def test_seq_and_displayed_counts_agree_with_the_underlying_data
    total = RegionalRubyKaigi::Loader.load.length

    past_count = @html[/これまでの開催 <span>（(\d+)開催）/, 1].to_i
    upcoming_count = @html.scan('class="upcoming-card"').length
    seq_values = @html.scan(/class="event-seq" value="(\d+)"/).flatten.map(&:to_i)

    assert_equal total, past_count + upcoming_count
    assert_equal total, seq_values.length
    assert_equal (1..total).to_a, seq_values.sort
  end

  private

  def event_anchor(href)
    match = @html.match(/<a class="(?:upcoming-card|event-title)" href="#{Regexp.escape(href)}"[^>]*>.*?<\/a>/m)
    refute_nil match, "event link not found: #{href}"
    match[0]
  end
end
