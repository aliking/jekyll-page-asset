# frozen_string_literal: true

require_relative "jekyll-page-asset/version"
begin
	require "jekyll_picture_tag"
rescue LoadError => e
	warn "[jekyll-page-asset] Missing dependency: jekyll_picture_tag (#{e.message})"
end
require_relative "../_plugins/page_asset"

module JekyllPageAsset
end
