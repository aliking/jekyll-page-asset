# frozen_string_literal: true

require "cgi"
require_relative "project_asset"

module Jekyll
  module ProjectAsset
    class VideoTag < Liquid::Tag
      include TagHelpers

      DISPLAY_BACKGROUND = "background"
      DISPLAY_FOREGROUND = "foreground"

      def initialize(tag_name, markup, options)
        super
        @video_asset_path, @rest, @params = parse_tag_markup(markup)

        raise SyntaxError, "#{tag_name}: first argument (video asset path) is required" if @video_asset_path.to_s.empty?
      end

      def render(context)
        video_path = project_asset_relative_path(context, @video_asset_path)
        return "" if video_path.nil? || video_path.empty?

        display = normalized_display(@params["display"])
        classes = display == DISPLAY_BACKGROUND ? "background-video" : "foreground-video"
        playback_attrs = display == DISPLAY_BACKGROUND ? "autoplay muted loop playsinline" : "controls playsinline"

        <<~HTML
          <video #{playback_attrs} class="#{classes}">
            <source src="/#{html_escape(video_path)}" type="#{html_escape(mime_type_for(video_path))}">
            Your browser does not support the video tag.
          </video>
        HTML
      end

      private

      def normalized_display(value)
        normalized = value.to_s.strip.downcase
        return DISPLAY_BACKGROUND if normalized == DISPLAY_BACKGROUND

        DISPLAY_FOREGROUND
      end

      def mime_type_for(path)
        case File.extname(path).downcase
        when ".webm"
          "video/webm"
        when ".ogv"
          "video/ogg"
        else
          "video/mp4"
        end
      end

      def html_escape(value)
        CGI.escape_html(value.to_s)
      end
    end
  end
end

Liquid::Template.register_tag("video", Jekyll::ProjectAsset::VideoTag)
