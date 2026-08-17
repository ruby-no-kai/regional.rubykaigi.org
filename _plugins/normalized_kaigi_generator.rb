# frozen_string_literal: true

require_relative "../lib/regional_ruby_kaigi/normalizer"

module RegionalRubyKaigi
  # `_data/events.yml` and `_data/kaigis/*.yml` are two different layouts
  # for the same data, for historical reasons (see RegionalRubyKaigi::
  # Normalizer for why); Jekyll needs them normalized into one
  # `site.data["events"]` array before anything renders. This Generator is
  # that Jekyll adapter — it runs during the generate stage, before pages
  # render — and leaves the actual normalizing to Normalizer.
  class NormalizedKaigiGenerator < Jekyll::Generator
    def generate(site)
      site.data["events"] = RegionalRubyKaigi.normalize_kaigis(site)
    end
  end
end
