# Regional RubyKaigi

This repository contains the Regional RubyKaigi event index and event websites hosted at
[regional.rubykaigi.org](https://regional.rubykaigi.org/). GitHub Pages publishes the `gh-pages` branch.

## Repository structure

- `_data/events.yml`: Regional RubyKaigi event data
- `index.html`: Jekyll template for the event index
- `_layouts/`: Shared layouts
- `<event-name>/`: Static pages for events hosted directly on this domain
- `stylesheets/`, `javascripts/`, `images/`: Shared assets for the index and archived sites
- `script/validate_events.rb`: Event data validation script
- `script/generate_og_image.rb`: OGP image generator for the event index

## Local development

Use Ruby 3.3 and install the dependencies:

```console
bundle install
```

Validate the event data:

```console
ruby script/validate_events.rb
```

The OGP image is generated from upcoming events in `_data/events.yml`.
Install `librsvg`, download the M PLUS 1 variable font from Google Fonts, then generate it before building the site:

```console
OG_IMAGE_FONT_FILE=/path/to/MPLUS1-wght.ttf ruby script/generate_og_image.rb
```

GitHub Actions installs these system dependencies and generates the image automatically.

Start the site with Jekyll, then open <http://localhost:4000/>:

```console
bundle exec jekyll serve
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution instructions.

## License

Code and documentation are provided under the [MIT License](LICENSE) unless otherwise noted.
Assets in archived event sites may be subject to separate rights or licenses.
