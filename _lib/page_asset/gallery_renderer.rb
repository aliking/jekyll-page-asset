# frozen_string_literal: true

require "cgi"

module Jekyll
  module PageAsset
    class GalleryRenderer < Renderer
      register_type 'gallery'

      SUPPORTED_IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp .avif .gif].freeze

      def render(context)
        return "" if @target_asset_paths.empty?

        gallery_asset_root = @asset_path_arg
        images = discover_images(@target_asset_paths)
        gallery_template = render_template(context, {})

        if images.empty?
          return empty_state_html(@asset_path_arg) + gallery_template
        end

        thumbnails = images.each_with_index.map do |filename, index|
          asset_path = File.join(gallery_asset_root, filename)
          supporting_text = get_supporting_text(context, asset_path)

          src = "/#{asset_path}"
          alt = supporting_text.dig(:args, 'alt') || alt_text_for(filename, index)
          description = supporting_text.dig(:body)
          picture_tag = render_thumbnail(context, asset_path)

          <<~HTML
            <button
              class="gallery-thumb"
              type="button"
              data-gallery-thumb="true"
              data-gallery-id="#{html_escape(@asset_path_arg)}"
              data-gallery-index="#{index}"
              data-gallery-src="#{html_escape(src)}"
              data-gallery-alt="#{html_escape(alt)}"
              data-gallery-desc="#{html_escape(description)}"
              aria-label="Open image #{index + 1}">
              #{picture_tag}
            </button>
          HTML
        end

        <<~HTML + gallery_template
          <section class="project-gallery" data-gallery="#{html_escape(@asset_path_arg)}" aria-label="Image gallery">
            <div class="project-gallery-grid">
              #{thumbnails.join("\n")}
            </div>
          </section>
        HTML
      end

      private

      def discover_images(paths)
        paths.select { |entry| SUPPORTED_IMAGE_EXTENSIONS.include?(File.extname(entry).downcase) }
           .sort_by(&:downcase)
      end

      def render_thumbnail(context, path)
        escaped_path = path.gsub('"', '\\"')
        liquid = "{% picture \"#{escaped_path}\" alt=\"thumbnail\" %}"
        Liquid::Template.parse(liquid).render(context)
      end

      def alt_text_for(filename, index)
        stem = File.basename(filename, File.extname(filename)).tr("_-", " ").strip
        return "Gallery image #{index + 1}" if stem.empty?

        stem.gsub(/\s+/, " ")
      end

      def get_supporting_text(context, path)
        # find supporting md file if it exists
        supporting_md = File.join(File.dirname(path) , File.basename(path, ".*") + ".md")
        if File.exist?(supporting_md)
          file_contents = File.read(supporting_md)
          site = context.registers[:site]

          if file_contents =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
            front_matter_string = $1
            body_content = $POSTMATCH # Captures everything after the front matter block

            # Parse the front matter string using Jekyll's internal parser
            front_matter = SafeYAML.load(front_matter_string)
          else
            body_content = file_contents
          end

          return {
            args: front_matter,
            body: site.find_converter_instance(Jekyll::Converters::Markdown)
                  .convert(body_content)
          }
        end
        {}
      end

      def empty_state_html(gallery_id)
        <<~HTML
          <section class="project-gallery" data-gallery="#{html_escape(gallery_id)}" aria-label="Image gallery">
            <p class="project-gallery-empty">No gallery images found.</p>
          </section>
        HTML
      end

      def html_escape(value)
        CGI.escape_html(value.to_s)
      end
    end
  end
end

