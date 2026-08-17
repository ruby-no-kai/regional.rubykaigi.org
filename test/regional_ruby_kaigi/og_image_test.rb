# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../../lib/regional_ruby_kaigi/og_image"

module RegionalRubyKaigi
  class OgImage
    class RendererTest < Minitest::Test
      def renderer
        Renderer.new
      end

      def kaigi(attributes)
        Kaigi.new(attributes)
      end

      def test_escapes_event_titles_in_svg
        svg = renderer.render_svg([kaigi("title" => "Ruby & Friends", "start_on" => Date.new(2026, 2, 1))])

        assert_includes svg, "Ruby &amp; Friends"
      end

      def test_limits_visible_events_and_reports_the_remaining_count
        kaigis = 7.times.map do |index|
          kaigi("title" => "Event #{index}", "start_on" => Date.new(2026, 2, index + 1))
        end

        svg = renderer.render_svg(kaigis)

        assert_includes svg, "Event 4"
        refute_includes svg, "Event 5"
        assert_includes svg, "ほか2件"
        assert_equal 5, svg.scan("<circle ").length # matches Renderer::MAX_UPCOMING
      end

      def test_renders_a_fallback_when_there_are_no_upcoming_events
        svg = renderer.render_svg([])

        assert_includes svg, "次回の開催をお楽しみに!!"
        assert_includes svg, "開催のお知らせをお待ちしています!!!q"
      end
    end

    class GenerateTest < Minitest::Test
      StubLoader = Struct.new(:kaigis) do
        def load = kaigis
      end

      def test_call_narrows_to_upcoming_kaigis_and_hands_them_to_the_renderer
        Dir.mktmpdir do |dir|
          output_path = File.join(dir, "og.png")
          version_path = File.join(dir, "og_image.yml")
          kaigis = [
            { "title" => "Past", "start_on" => Date.new(2026, 1, 1) },
            { "title" => "Upcoming", "start_on" => Date.new(2026, 3, 1) }
          ]
          rendered = nil
          renderer = Object.new
          renderer.define_singleton_method(:render_to) do |out, drawn|
            rendered = [out, drawn]
            File.write(out, "stub png bytes")
            out
          end

          destination = OgImage::Generate::Destination.new(output_path: output_path, version_path: version_path)

          result = OgImage.generate(
            Date.new(2026, 2, 1),
            loader: StubLoader.new(kaigis),
            renderer: renderer,
            destination: destination
          )

          assert_instance_of OgImage, result
          assert_equal output_path, result.path
          assert_equal output_path, rendered.first
          assert_equal ["Upcoming"], rendered.last.map(&:title)
          assert_match(/^digest: [0-9a-f]{12}$/, File.read(version_path).strip)
        end
      end
    end
  end
end
