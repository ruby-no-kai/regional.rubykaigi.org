# frozen_string_literal: true

require "minitest/autorun"
require "jekyll"
require "tmpdir"
require "rexml/document"

class IndexRssRenderingTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def self.rendered_rss
    @rendered_rss ||= Dir.mktmpdir("regional-rubykaigi-site") do |destination|
      # See index_rendering_test.rb for why this has to run exactly the
      # way `bundle exec jekyll build` does.
      Dir.chdir(ROOT) { Jekyll::PluginManager.require_from_bundler }

      config = Jekyll.configuration(
        "source" => ROOT,
        "destination" => destination,
        "quiet" => true
      )
      Jekyll::Site.new(config).process
      File.read(File.join(destination, "index.rss"))
    end
  end

  def setup
    @doc = REXML::Document.new(self.class.rendered_rss)
  end

  def test_root_is_an_rss_2_0_document
    assert_equal "rss", @doc.root.name
    assert_equal "2.0", @doc.root.attributes["version"]
  end

  def test_channel_has_the_expected_metadata
    channel = @doc.root.elements["channel"]

    assert_equal "Regional RubyKaigi", channel.elements["title"].text
    assert_equal "https://regional.rubykaigi.org/", channel.elements["link"].text
  end

  # `_data/kaigis/` only has entries once organizers add them, and
  # `_data/events.yml`'s legacy entries never get an added_on (see
  # GitAddedOn) — so the right item count is whatever's on disk right now,
  # capped at 20, not a number to hardcode here.
  def test_item_count_matches_the_kaigis_directory_capped_at_20
    kaigis_count = Dir.glob(File.join(ROOT, "_data", "kaigis", "*.{yml,yaml}")).length
    items = @doc.root.elements["channel"].get_elements("item")

    assert_equal [kaigis_count, 20].min, items.length
  end

  def test_every_item_has_an_absolute_link_and_a_pub_date
    items = @doc.root.elements["channel"].get_elements("item")

    items.each do |item|
      assert_match %r{\Ahttps://}, item.elements["link"].text
      assert_match %r{\Ahttps://}, item.elements["guid"].text
      refute_nil item.elements["pubDate"].text
    end
  end
end
