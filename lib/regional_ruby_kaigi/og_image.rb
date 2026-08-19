# frozen_string_literal: true

require "cgi/escape"
require "digest"
require "erb"
require "fileutils"
require "open3"
require "tempfile"
require "tmpdir"
require_relative "../regional_ruby_kaigi"

module RegionalRubyKaigi
  # A generated OG:image PNG: where it lives and the dimensions it was
  # rendered at. `.generate` produces one; `Renderer` and `Generate` are how
  # — this class itself doesn't draw anything.
  class OgImage
    WIDTH = 1200
    HEIGHT = 630
    private_constant :WIDTH, :HEIGHT

    def self.generate(...) = Generate.call(...)

    attr_reader :path

    def initialize(path:)
      @path = path
    end

    def width = WIDTH
    def height = HEIGHT

    # Draws a kaigi list as the OG:image PNG: the SVG card layout, the CJK
    # font setup, and the rsvg-convert invocation. Doesn't know where the
    # kaigi list comes from or which of them count as upcoming — it's just
    # handed what to draw.
    class Renderer
      MAX_UPCOMING = 5
      FONT_PATH = File.expand_path("../../script/assets/MPLUS1-wght.ttf", __dir__).freeze
      SVG_TEMPLATE = ERB.new(File.read(File.expand_path("og_image.svg.erb", __dir__)), trim_mode: "-").freeze
      private_constant :MAX_UPCOMING, :FONT_PATH, :SVG_TEMPLATE

      def self.render_to(...) = new.render_to(...)

      def initialize(font_path: FONT_PATH)
        @font_path = font_path
      end

      def render_to(output_path, kaigis)
        FileUtils.mkdir_p(File.dirname(output_path))

        Tempfile.create(["regional-rubykaigi-og", ".svg"]) do |file|
          file.write(render_svg(kaigis))
          file.flush
          with_font_environment do |environment|
            _stdout, stderr, status = Open3.capture3(
              environment,
              "rsvg-convert", "--width", WIDTH.to_s, "--height", HEIGHT.to_s,
              "--output", output_path, file.path
            )
            raise "rsvg-convert failed: #{stderr}" unless status.success?
          end
        end

        output_path
      end

      def render_svg(kaigis)
        visible_kaigis = kaigis.first(MAX_UPCOMING)
        remaining_count = kaigis.length - visible_kaigis.length
        card_height = visible_kaigis.empty? ? 144 : 44 + (visible_kaigis.length * 52)
        remaining_label = remaining_count.positive? ? "ほか#{remaining_count}件" : ""

        SVG_TEMPLATE.result(binding)
      end

      private

      def font_path = File.expand_path(@font_path)
      def font_dir = File.dirname(font_path)

      def with_font_environment
        raise "OGP font not found: #{font_path}" unless File.file?(font_path)

        Dir.mktmpdir("regional-rubykaigi-fontconfig") do |cache_dir|
          Tempfile.create(["fonts", ".conf"]) do |config|
            config.write(<<~XML)
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
              <fontconfig>
                <dir>#{CGI.escapeHTML(font_dir)}</dir>
                <cachedir>#{CGI.escapeHTML(cache_dir)}</cachedir>
              </fontconfig>
            XML
            config.flush
            yield("FONTCONFIG_FILE" => config.path)
          end
        end
      end
    end

    # The CLI entrypoint: asks RegionalRubyKaigi for what's upcoming, hands
    # that to `renderer` to draw, and writes the cache-busting digest.
    # Doesn't know how a kaigi list is read or how a PNG actually gets drawn
    # — both are injected so this stays about orchestration only, and tests
    # can swap in doubles instead of hitting the filesystem or shelling out
    # to rsvg-convert (which CI doesn't even have installed).
    class Generate
      # Where a generation writes its output — not a collaborator (it has no
      # behavior of its own), just two path values that belong together.
      Destination = Data.define(:output_path, :version_path)

      DEFAULT_DESTINATION = Destination.new(
        output_path: File.expand_path("../../images/og/regional-rubykaigi.png", __dir__).freeze,
        version_path: File.expand_path("../../_data/og_image.yml", __dir__).freeze
      )
      private_constant :DEFAULT_DESTINATION

      def self.call(today = RegionalRubyKaigi.japan_today, **collaborators) = new(**collaborators).call(today)

      def initialize(loader: Loader, renderer: Renderer, destination: DEFAULT_DESTINATION)
        @loader = loader
        @renderer = renderer
        @destination = destination
      end

      def call(today = RegionalRubyKaigi.japan_today)
        kaigis = RegionalRubyKaigi.upcoming(today, loader: @loader)
        @renderer.render_to(@destination.output_path, kaigis)

        File.write(@destination.version_path, "digest: #{cache_busting_digest(@destination.output_path)}\n")

        OgImage.new(path: @destination.output_path)
      end

      private

      # A short hash of the rendered image's bytes, so the page's <img> tag
      # can bust caches only when the image content actually changes rather
      # than on every deploy.
      def cache_busting_digest(path)
        Digest::SHA256.file(path).hexdigest[0, 12]
      end
    end
  end
end
