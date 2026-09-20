# frozen_string_literal: true

require "cgi"

module Jekyll
  module PageAsset
    class AudioRenderer < Renderer
      register_type "audio"

      def render(context)
        audio_path = @target_asset_path

        <<~HTML
          <audio controls preload="auto" class="page-asset-audio">
            <source src="/#{html_escape(audio_path)}" type="#{html_escape(mime_type_for(audio_path))}">
            Your browser does not support the audio tag.
          </audio>
        HTML
      end

      private

      def mime_type_for(path)
        case File.extname(path).downcase
        when ".ogg"
          "audio/ogg"
        when ".wav"
          "audio/wav"
        when ".m4a"
          "audio/mp4"
        else
          "audio/mpeg"
        end
      end

      def html_escape(value)
        CGI.escape_html(value.to_s)
      end
    end
  end
end
