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

  module_function

  def japan_today(now = Time.now)
    now.getlocal("+09:00").to_date
  end

  def upcoming_event(events, today: japan_today)
    events
      .select { |event| date(event.fetch("start_on")) >= today }
      .min_by { |event| date(event.fetch("start_on")) }
  end

  def render_svg(event)
    title = event ? event.fetch("title") : "次回の開催をお楽しみに"
    date_label = event ? date(event.fetch("start_on")).iso8601 : "日本各地のRubyコミュニティイベント"
    title_size = [[900 / title.length, 70].min, 42].max

    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="#{WIDTH}" height="#{HEIGHT}" viewBox="0 0 #{WIDTH} #{HEIGHT}">
        <rect width="1200" height="630" fill="#fffdfb"/>
        <rect x="64" y="64" width="1072" height="502" rx="28" fill="#fff5f2" stroke="#eadfdb" stroke-width="2"/>
        <rect x="64" y="64" width="12" height="502" rx="6" fill="#a52a32"/>
        <text x="128" y="148" fill="#a52a32" font-family="monospace" font-size="26" font-weight="700" letter-spacing="2">REGIONAL RUBYKAIGI</text>
        <text x="128" y="224" fill="#302b29" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="48" font-weight="800">地域Ruby会議</text>
        <text x="128" y="318" fill="#a52a32" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="30" font-weight="700">これからの開催</text>
        <text x="128" y="408" fill="#302b29" font-family="'Noto Sans CJK JP', 'Noto Sans JP', sans-serif" font-size="#{title_size}" font-weight="800">#{CGI.escapeHTML(title)}</text>
        <text x="132" y="474" fill="#6a605c" font-family="monospace" font-size="30" font-weight="700">#{CGI.escapeHTML(date_label)}</text>
        <text x="128" y="530" fill="#6a605c" font-family="monospace" font-size="22">regional.rubykaigi.org</text>
      </svg>
    SVG
  end

  def generate(data_file: DATA_FILE, output_file: OUTPUT_FILE, today: japan_today)
    events = YAML.safe_load_file(data_file, permitted_classes: [Date], aliases: false)
    svg = render_svg(upcoming_event(events, today: today))
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
