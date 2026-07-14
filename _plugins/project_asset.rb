# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll
  module ProjectAsset
    module TagHelpers
      private

      def parse_tag_markup(markup)
        normalized_markup = markup.to_s.strip
        return [nil, "", {}] if normalized_markup.empty?

        first_arg, rest = normalized_markup.split(/\s+/, 2)
        rest ||= ""

        params = {}
        rest.scan(/(\w+)=(?:'([^']*)'|"([^"]*)"|(\S+))/) do |key, sq, dq, bare|
          params[key] = sq || dq || bare
        end

        [first_arg, rest, params]
      end

      def tag_site(context)
        context.registers[:site]
      end

      def tag_page(context)
        context.registers[:page]
      end

      def project_slug_from_context(context)
        page = tag_page(context)
        page_url = page["url"] || page.url
        page_url.to_s.split("/").reject(&:empty?).last
      end

      def project_asset_root
        Jekyll.configuration.dig("project_asset", "asset_root") || "assets/project_media"
      end

      def project_asset_relative_path(context, *segments)
        project_slug = project_slug_from_context(context)
        return nil if project_slug.nil? || project_slug.empty?

        File.join(project_asset_root, project_slug, *segments.compact)
      end

      def project_asset_source_path(context, *segments)
        relative_path = project_asset_relative_path(context, *segments)
        return nil if relative_path.nil?

        File.join(tag_site(context).source, relative_path)
      end
    end

    class ProjectAssetTag < Liquid::Tag
      include TagHelpers

      def initialize(tag_name, markup, options)
        super

        # Split the markup into file name and opts.
        @filename, @rest = parse_tag_markup(markup)
      end

      def render(context) # rubocop:disable Metrics/PerceivedComplexity
        fullpath = project_asset_relative_path(context, @filename)
        return "" if fullpath.nil? || fullpath.empty?

        augmented_liquid = "{% picture #{fullpath} #{@rest} %}"
        Liquid::Template.parse(augmented_liquid).render(context)
      end
    end
  end
end

Liquid::Template.register_tag("project_asset", Jekyll::ProjectAsset::ProjectAssetTag)
