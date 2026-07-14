# frozen_string_literal: true

require "net/http"
require "base64"
require_relative "project_asset"

module Jekyll
  module ProjectAsset
    class FountainTag < Liquid::Tag
      include TagHelpers

      def initialize(tag_name, markup, options)
        super

        # Split the markup into file name and opts.
        @filename, @rest = parse_tag_markup(markup)
      end

      def render(context)
        site = tag_site(context)
        include_path = File.join(site.source, "_includes", "fountain.html")

        unless File.exist?(include_path)
          raise IOError, "fountain: include file not found at #{include_path}"
        end

        full_script_path = project_asset_source_path(context, @filename)
        return "" if full_script_path.nil? || full_script_path.empty?

        script_text = File.read(full_script_path)

        template = Liquid::Template.parse(File.read(include_path))

        context["include"] = { "script_text" => script_text }
        template.render(context)
      end
    end
  end
end


Liquid::Template.register_tag("fountain", Jekyll::ProjectAsset::FountainTag)
