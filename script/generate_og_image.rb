#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "open3"
require "tempfile"
require "yaml"

module OgImageGenerator
  DATA_FILE = File.expand_path("../_data/events.yml", __dir__)
  OUTPUT_FILE = File.expand_path("../images/og/regional-rubykaigi.png", __dir__)
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
    event_rows = if visible_events.empty?
      <<~SVG
        <text x="128" y="388" fill="#302b29" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="52" font-weight="800">次回の開催をお楽しみに</text>
        <text x="132" y="452" fill="#6a605c" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="28">日本各地のRubyコミュニティイベント</text>
      SVG
    else
      visible_events.each_with_index.map do |event, index|
        title = event.fetch("title")
        title_size = [[680 / title.length, 38].min, 28].max
        baseline = 326 + (index * 54)
        <<~SVG
          <text x="128" y="#{baseline}" fill="#a52a32" font-family="monospace" font-size="25" font-weight="700">#{date(event.fetch("start_on")).iso8601}</text>
          <text x="390" y="#{baseline}" fill="#302b29" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="#{title_size}" font-weight="800">#{CGI.escapeHTML(title)}</text>
        SVG
      end.join
    end
    remaining_label = remaining_count.positive? ? "ほか#{remaining_count}件" : ""

    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="#{WIDTH}" height="#{HEIGHT}" viewBox="0 0 #{WIDTH} #{HEIGHT}">
        <rect width="1200" height="630" fill="#fffdfb"/>
        <rect x="64" y="64" width="1072" height="502" rx="28" fill="#fff5f2" stroke="#eadfdb" stroke-width="2"/>
        <rect x="64" y="64" width="12" height="502" rx="6" fill="#a52a32"/>
        <text x="128" y="138" fill="#a52a32" font-family="monospace" font-size="26" font-weight="700" letter-spacing="2">REGIONAL RUBYKAIGI</text>
        <text x="1072" y="138" text-anchor="end" fill="#6a605c" font-family="monospace" font-size="20">regional.rubykaigi.org</text>
        <text x="128" y="208" fill="#302b29" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="48" font-weight="800">地域Ruby会議</text>
        <text x="128" y="268" fill="#a52a32" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="28" font-weight="700">これからの開催</text>
        <text x="1072" y="268" text-anchor="end" fill="#6a605c" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="22">#{remaining_label}</text>
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
      _stdout, stderr, status = Open3.capture3(
        "rsvg-convert", "--width", WIDTH.to_s, "--height", HEIGHT.to_s,
        "--output", output_file, file.path
      )
      raise "rsvg-convert failed: #{stderr}" unless status.success?
    end

    output_file
  end

  def date(value)
    value.is_a?(Date) ? value : Date.iso8601(value.to_s)
  end
end

if $PROGRAM_NAME == __FILE__
  output_file = OgImageGenerator.generate
  puts "Generated #{output_file} (#{OgImageGenerator::WIDTH}x#{OgImageGenerator::HEIGHT})"
end
