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

## Local development

Use Ruby 3.3 and install the dependencies:

```console
bundle install
```

Validate the event data:

```console
ruby script/validate_events.rb
```

Start the site with Jekyll, then open <http://localhost:4000/>:

```console
bundle exec jekyll serve
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution instructions.

## License

Code and documentation are provided under the [MIT License](LICENSE) unless otherwise noted.
Assets in archived event sites may be subject to separate rights or licenses.
