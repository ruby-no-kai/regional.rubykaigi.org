#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/regional_ruby_kaigi/og_image"

include RegionalRubyKaigi

og_image = OgImage.generate(japan_today)
puts "Generated #{og_image.path} (#{og_image.width}x#{og_image.height})"
