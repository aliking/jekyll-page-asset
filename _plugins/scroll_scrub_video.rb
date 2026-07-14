# frozen_string_literal: true

require_relative "project_asset"

module Jekyll
  module ProjectAsset
    class ScrollScrubVideoTag < Liquid::Tag
      include TagHelpers

      DEFAULTS = {
        "pixels_per_second" => 50,
        "sticky_top" => 120
      }.freeze

      def initialize(tag_name, markup, options)
        super
        @video_asset_path, @rest, @params = parse_tag_markup(markup)
        raise SyntaxError, "#{tag_name}: first argument (video asset path) is required" if @video_asset_path.to_s.empty?
      end

      def render(context)
        site = tag_site(context)
        include_path = File.join(site.source, "_includes", "scroll_scrub_video.html")

        unless File.exist?(include_path)
          raise IOError, "scroll_scrub_video: include file not found at #{include_path}"
        end

        template = Liquid::Template.parse(File.read(include_path))

        full_video_path = project_asset_relative_path(context, @video_asset_path)
        return "" if full_video_path.nil? || full_video_path.empty?

        include_vars = {
          "video_path"        => full_video_path,
          "pixels_per_second" => (@params["pixels_per_second"] || DEFAULTS["pixels_per_second"]).to_i,
          "sticky_top"        => (@params["sticky_top"] || DEFAULTS["sticky_top"]).to_i
        }

        context.stack do
          context["include"] = include_vars
          template.render(context)
        end
      end
    end
  end
end

Liquid::Template.register_tag("scroll_scrub_video", Jekyll::ProjectAsset::ScrollScrubVideoTag)
