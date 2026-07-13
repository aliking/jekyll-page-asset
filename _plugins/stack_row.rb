# frozen_string_literal: true

require 'cgi'

# Registers the `stack_row` Liquid tag.
#
# Usage:
#   {% stack_row tape project=project current_url=include.current_url %}
#
# The first argument is the row type (currently only "tape" is supported).
# Named parameters are resolved as Liquid variables from the calling context.
#
# Transform limits and seed are read from _config.yml:
#   stack_transform:
#     seed: 42
#     translate_max: 20
#     rotate_max: 7

module Jekyll
  class StackRowTag < Liquid::Tag
    TAPE_SVG_INCLUDE = File.join('_includes', 'components', 'sidebar', 'tape.svg')

    def initialize(tag_name, markup, tokens)
      super
      parts = markup.strip.split(/\s+/, 2)
      @row_type   = parts[0].to_s.strip
      @raw_params = parts[1].to_s
    end

    def render(context)
      params = {}
      @raw_params.scan(/(\w+)=([\w.]+)/) do |key, val|
        params[key] = context[val]
      end

      project     = params['project']
      current_url = params['current_url'].to_s
      return '' if project.nil?

      site        = context.registers[:site]
      cfg         = site.config.fetch('stack_transform', {})
      seed        = cfg.fetch('seed', 42).to_i
      tx_max      = cfg.fetch('translate_max', 20).to_f
      ry_max      = cfg.fetch('rotate_max', 7).to_f

      project_url = project.url.to_s
      translate_x = seeded_rand("#{project_url}tx", seed, -tx_max, tx_max)
      rotate_y    = seeded_rand("#{project_url}ry", seed, -ry_max, ry_max)

      is_current  = current_url.include?(project_url)
      link_class  = is_current ? 'project-stack-item disabled' : 'project-stack-item'
      style_class = project['stack_style'].to_s.strip
      art_class   = ['project-stack-item-art', style_class].reject(&:empty?).join(' ')
      baseurl     = site.config['baseurl'].to_s
      href        = "#{baseurl}#{project_url}"
      title       = CGI.escape_html(project['title'].to_s.upcase)
      tape_svg    = read_tape_svg(site)

      <<~HTML
        <div class="project-stack-item-row">
          <a class="#{link_class}" style="transform: translateX(#{translate_x}px) rotateY(#{rotate_y}deg);" href="#{href}">
            <div class="#{art_class}" aria-hidden="true">
              #{tape_svg}
            </div>
            <div class="project-stack-item-label" aria-hidden="true">
              <svg viewBox="0 0 500 50" width="100%" role="presentation" focusable="false">
                <text x="0" y="40" font-size="40" font-weight="700" textLength="100%" lengthAdjust="spacingAndGlyphs">#{title}</text>
              </svg>
            </div>
          </a>
        </div>
      HTML
    end

    private

    # Deterministic pseudo-random float in [min, max] keyed on input string + seed.
    # Byte-based hash is stable across Ruby versions (String#hash is randomized).
    def seeded_rand(input, seed, min, max)
      stable = input.bytes.each_with_index.inject(0) { |acc, (b, i)| acc + b * (31**i) }
      rng    = Random.new(seed + stable)
      (rng.rand * (max - min) + min).round(2)
    end

    # Read the tape SVG, stripping the <defs> block from all copies after the
    def read_tape_svg(site)
      File.read(File.join(site.source, TAPE_SVG_INCLUDE)).strip
    rescue Errno::ENOENT
      ''
    end
  end
end

Liquid::Template.register_tag('stack_row', Jekyll::StackRowTag)
