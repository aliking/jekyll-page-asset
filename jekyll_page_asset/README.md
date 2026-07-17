## Run crappy demo site locally

bundle install
bundle exec jekyll serve --livereload

# jekyll_page_asset

The `page_asset` plugin designed for a project portfolio style ( although it might well work with blog/post style layouts) to make it easy to put assets that relate to a page, onto that page.

It's essentially a convenience tag for adding components that reference media files into project pages. The media files are stored in the `assets/project_media/<project-slug>/` folder and can be referenced by just a relative path to that folder.

The intent is to make it easy to add media components into project pages by defining a simple set of the most likely needed. Users should be able to stay in markdown writing flow and not think too much about page structure.


## Supported components
### image
Standard image. This delegates to the `jekyll_picture_tag` plugin which handles responsive images. Any args past the filename are passed through to that plugin, so you can use any of the options it supports.

`{% raw %}{% page_asset image <image-filename> [alt="<alt-text>"] %}{% endraw %}`

### foreground video
i.e. a video that is embedded in the page and can be played by the user.

`{% raw %}{% page_asset video <video-filename> %}{% endraw %}`

### background video
i.e. video that loads and autoplays muted by default.

`{% raw %}{% page_asset video <video-filename> display=background %}{% endraw %}`

### scroll scrub video
Video that loads muted and advances as the user scrolls the page.

`{% raw %}{% page_asset scroll_scrub_video <video-filename> %}{% endraw %}`

### gallery
Pass a folder name in the media asset directory and all images in that folder will be displayed in a gallery.
The generated html and script for this will also write tags to two target mount points in the site, if found.
`project-asset-gallery-lightbox` is the target for the lightbox html. By default this is styled to fill the viewport area of the component that it is mounted in to act as a full area takeover.
`project-asset-gallery-controls` is the target for the gallery controls - to move to next/previous images and close the lightbox. This appears when the lightbox is open.
`{% raw %}{% page_asset gallery <gallery-folder-name> %}{% endraw %}`

### fountain script reader
Simple scrollable script reader for [fountain](https://fountain.io/){:target="_blank"} formatted scripts.
`{% raw %}{% page_asset fountain <fountain-filename> %}{% endraw %}`

# Styling
Page asset components styles are in `_sass/page_asset.scss`. Every one of the components is rendered in a container with class `page-asset-container`

# Configuration
The plugin can be configured in `_config.yml` with the following options:

``` yaml
page_asset:
  asset_root: assets/project_media
```
where asset_root is the root folder for all project media assets.


# Custom components
Custom components are defined by adding:

A custom type renderer in `_lib/page_asset/`

OR

A custom html template in `_includes/page_asset/`


or both. There are examples each kind in the current supported types.

## Custom renderer
A custom renderer is a class that inherits from `PageAsset::Renderer`, sets `register_type <type>` and implements a `render(context)` method.

A renderer can directly return html:
``` ruby
module Jekyll
  module PageAsset
    class DummyRenderer < Renderer
      register_type 'dummy'

      def render(context)
        <<~HTML
            <div style="background-color: red; color: white; padding: 1rem;">
              full path is #{@target_asset_path}
            </div>
        HTML
      end
    end
  end
end
```
and has the following variables available:

| @type | component type string |
| @asset_path_arg | requested path argument from the tag |
| @rest | all the rest of the args from the tag (useful for passing through) |
| @params | A hash of any tag args that were specified like key=value |
| @target_asset_paths | An array of the full resolved paths to assets (for single files this is an array with one item) |
| @target_asset_path | convenience - the first item from the above array |

Or it can load a custom html template from `_includes/page_asset/` and pass variables to it. The above variables are available in `include` but you can derive and pass any other variable.

``` ruby
module Jekyll
  module PageAsset
    class DummyRenderer < Renderer
      register_type 'dummy'

      def render(context)
        include_vars = build_include_vars(
          "dummy_string" => @target_asset_path + " is the full path to the asset"
        )
        render_template(context, include_vars)
      end
    end
  end
end
```
This is expecting to find a template file `_includes/page_asset/dummy.html`. e.g.:

``` html
<div style="background-color: red; color: white; padding: 1rem;">
  {{ include.dummy_string }}
</div>
```

If there is no custom renderer, but there is a custom template, the template will be rendered with the above variables available in `include`.

Follow convention to put any styles for the custom component in `_sass/page_asset.scss`.
