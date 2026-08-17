#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/regional_ruby_kaigi/cli"

exit RegionalRubyKaigi::CLI.validate_kaigis if $PROGRAM_NAME == __FILE__
