# frozen_string_literal: true

require_relative "../lib/regional_ruby_kaigi"
require_relative "../lib/regional_ruby_kaigi/git_added_on"

module RegionalRubyKaigi
  # `_data/events.yml` and `_data/kaigis/*.yml` are two different layouts
  # for the same data, for historical reasons (see RegionalRubyKaigi::
  # Normalizer for why); Jekyll needs them normalized into one
  # `site.data["events"]` array before anything renders. This Generator is
  # that Jekyll adapter — it runs during the generate stage, before pages
  # render — and leaves the actual normalizing to Normalizer.
  class NormalizedKaigiGenerator < Jekyll::Generator
    def generate(site)
      site.data["events"] = RegionalRubyKaigi.normalize_kaigis(site, added_on: added_on_by_filename(site))
    end

    private

    # GitAddedOn needs a filepath, but `site.data["kaigis"]` (Jekyll's own
    # parsed copy) only has the parsed YAML, keyed by filename — so re-glob
    # `_data/kaigis/` here, the same way Loader#kaigi_files does, to find
    # the file behind each filename.
    def added_on_by_filename(site)
      kaigi_dir = File.join(site.source, "_data", "kaigis")
      (site.data["kaigis"] || {}).keys.to_h do |filename|
        filepath = Dir.glob(File.join(kaigi_dir, "#{filename}.{yml,yaml}")).first
        [filename, filepath && GitAddedOn.for(filepath)]
      end
    end
  end
end
