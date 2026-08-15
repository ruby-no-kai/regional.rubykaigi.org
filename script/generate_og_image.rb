#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "open3"
require "tempfile"
require "tmpdir"
require "yaml"

module OgImageGenerator
  DATA_FILE = File.expand_path("../_data/events.yml", __dir__)
  OUTPUT_FILE = File.expand_path("../images/og/regional-rubykaigi.png", __dir__)
  FONT_FILE = File.expand_path("assets/MPLUS1-wght.ttf", __dir__)
  WIDTH = 1200
  HEIGHT = 630
  MAX_EVENTS = 5

  module_function

  def japan_today(now = Time.now)
    now.getlocal("+09:00").to_date
  end

  def upcoming_events(events, today: japan_today)
    events
      .select { |event| date(event.fetch("start_on")) >= today }
      .sort_by { |event| date(event.fetch("start_on")) }
  end

  def render_svg(events)
    visible_events = events.first(MAX_EVENTS)
    remaining_count = events.length - visible_events.length
    card_height = visible_events.empty? ? 144 : 44 + (visible_events.length * 52)
    event_rows = if visible_events.empty?
      <<~SVG
        <text x="128" y="332" fill="#302b29" font-family="'M PLUS 1'" font-size="42" font-weight="800">次回の開催をお楽しみに!!</text>
        <text x="130" y="380" fill="#6a605c" font-family="'M PLUS 1'" font-size="24">開催のお知らせをお待ちしています!!!q</text>
      SVG
    else
      visible_events.each_with_index.map do |event, index|
        title = event.fetch("title")
        title_size = [[680 / title.length, 38].min, 28].max
        baseline = 316 + (index * 52)
        <<~SVG
          <circle cx="124" cy="#{baseline - 9}" r="5" fill="#a52a32"/>
          <text x="148" y="#{baseline}" fill="#a52a32" font-family="'M PLUS 1'" font-size="23" font-weight="700">#{date(event.fetch("start_on")).iso8601}</text>
          <text x="390" y="#{baseline}" fill="#302b29" font-family="'M PLUS 1'" font-size="#{title_size}" font-weight="800">#{CGI.escapeHTML(title)}</text>
        SVG
      end.join
    end
    remaining_label = remaining_count.positive? ? "ほか#{remaining_count}件" : ""

    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="#{WIDTH}" height="#{HEIGHT}" viewBox="0 0 #{WIDTH} #{HEIGHT}">
        <rect width="1200" height="630" fill="#ffffff"/>
        <text x="80" y="82" fill="#a52a32" font-family="'M PLUS 1'" font-size="22" font-weight="700" letter-spacing="2">REGIONAL RUBYKAIGI</text>
        <text x="1120" y="82" text-anchor="end" fill="#6a605c" font-family="'M PLUS 1'" font-size="18">regional.rubykaigi.org</text>
        <text x="80" y="154" fill="#302b29" font-family="'M PLUS 1'" font-size="48" font-weight="900">地域Ruby会議</text>
        <text x="80" y="238" fill="#302b29" font-family="'M PLUS 1'" font-size="27" font-weight="700">これからの開催</text>
        <text x="1120" y="238" text-anchor="end" fill="#6a605c" font-family="'M PLUS 1'" font-size="20">#{remaining_label}</text>
        <rect x="80" y="264" width="1040" height="#{card_height}" rx="16" fill="#fff5f2" stroke="#eadfdb" stroke-width="2"/>
        <rect x="80" y="264" width="10" height="#{card_height}" rx="5" fill="#a52a32"/>
        #{event_rows}
      </svg>
    SVG
  end

  def generate(data_file: DATA_FILE, output_file: OUTPUT_FILE, today: japan_today)
    events = YAML.safe_load_file(data_file, permitted_classes: [Date], aliases: false)
    svg = render_svg(upcoming_events(events, today: today))
    FileUtils.mkdir_p(File.dirname(output_file))

    Tempfile.create(["regional-rubykaigi-og", ".svg"]) do |file|
      file.write(svg)
      file.flush
      with_font_environment do |environment|
        _stdout, stderr, status = Open3.capture3(
          environment,
          "rsvg-convert", "--width", WIDTH.to_s, "--height", HEIGHT.to_s,
          "--output", output_file, file.path
        )
        raise "rsvg-convert failed: #{stderr}" unless status.success?
      end
    end

    output_file
  end

  def date(value)
    value.is_a?(Date) ? value : Date.iso8601(value.to_s)
  end

  def with_font_environment
    font_file = ENV.fetch("OG_IMAGE_FONT_FILE", FONT_FILE)
    raise "OGP font not found: #{font_file}" unless File.file?(font_file)

    Dir.mktmpdir("regional-rubykaigi-fontconfig") do |cache_dir|
      Tempfile.create(["fonts", ".conf"]) do |config|
        config.write(<<~XML)
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <dir>#{CGI.escapeHTML(File.dirname(File.expand_path(font_file)))}</dir>
            <cachedir>#{CGI.escapeHTML(cache_dir)}</cachedir>
          </fontconfig>
        XML
        config.flush
        yield("FONTCONFIG_FILE" => config.path)
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  output_file = OgImageGenerator.generate
  puts "Generated #{output_file} (#{OgImageGenerator::WIDTH}x#{OgImageGenerator::HEIGHT})"
end
