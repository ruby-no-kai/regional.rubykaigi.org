# Regional RubyKaigi

This repository contains the Regional RubyKaigi event index and event websites hosted at
[regional.rubykaigi.org](https://regional.rubykaigi.org/). GitHub Pages publishes the `gh-pages` branch.

## Repository structure

- `_data/events.yml`, `_data/kaigis/*.yml`: Regional RubyKaigi event data
- `index.html`: Jekyll template for the event index
- `index.rss`: RSS feed of the most recently added `_data/kaigis/` entries (see `CONTRIBUTING.md`)
- `_layouts/`: Shared layouts
- `<event-name>/`: Static pages for events hosted directly on this domain
- `stylesheets/`, `javascripts/`, `images/`: Shared assets for the index and archived sites
- `script/validate_kaigis.rb`: Event data validation script
- `script/generate_og_image.rb`: OGP image generator for the event index
- `script/assets/`: Build-only assets, including the OFL-licensed M PLUS 1 font

## Local development

Use Ruby 3.3 and install the dependencies:

```console
bundle install
```

Validate the event data:

```console
ruby script/validate_kaigis.rb
```

The OGP image is generated from upcoming events in `_data/events.yml` and `_data/kaigis/`.
Install `librsvg`, then generate it before building the site. The required M PLUS 1 font is included in `script/assets/`.

```console
ruby script/generate_og_image.rb
```

The GitHub Pages deployment workflow installs this system dependency and generates the image automatically.

Start the site with Jekyll, then open <http://localhost:4000/>:

```console
bundle exec jekyll serve
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution instructions.

## License

Code and documentation are provided under the [MIT License](LICENSE) unless otherwise noted.
Assets in archived event sites may be subject to separate rights or licenses.
The bundled M PLUS 1 font is provided under the SIL Open Font License 1.1 in `script/assets/MPLUS1-OFL.txt`.
