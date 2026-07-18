# frozen_string_literal: true

require_relative "lib/jekyll-page-asset/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-page-asset"
  spec.version       = JekyllPageAsset::VERSION
  spec.authors       = ["Alastair King"]
  spec.email         = ["ali@kinginterweb.com"]
  spec.summary       = "Liquid tag plugin for project page assets in Jekyll"
  spec.description   = "Provides the page_asset Liquid tag and renderers for image, gallery, video, fountain, and scroll-scrub assets."
  spec.homepage      = "https://example.com"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir[
    "lib/**/*",
    "_plugins/page_asset.rb",
    "_lib/page_asset/**/*",
    "_includes/page_asset/**/*",
    "_sass/_page-asset.scss",
    "LICENSE",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", ">= 4.0", "< 5.0"
  spec.add_runtime_dependency "jekyll_picture_tag", ">= 2.0", "< 3.0"
end
