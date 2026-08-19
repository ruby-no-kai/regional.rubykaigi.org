# Repository guidelines

## Purpose

This repository publishes the Regional RubyKaigi index and archives event websites on GitHub Pages.

## Working agreements

- Preserve historical event sites. Do not reformat, modernize, or remove unrelated archived files.
- Treat `_data/events.yml` plus `_data/kaigis/*.yml` together as the source of truth for the event index. Add new events as individual files under `_data/kaigis/`, not by appending to `_data/events.yml`.
- Keep event `name` values (explicit or filename-derived) stable; they may also be public URL paths.
- Use `YYYY-MM-DD` dates.
- Prefer HTTPS for new external and report URLs.
- Run `ruby script/validate_kaigis.rb` after changing event data.
- Check relative links and assets when adding or changing an event site.
- When a change affects documented behavior or contributor workflows, update the directly related documentation in the same change. Do not update unrelated documentation.
- Never rewrite the history of `gh-pages`.
- Do not push to `gh-pages` unless the user explicitly requests it.

See `README.md` for the repository overview and `CONTRIBUTING.md` for the data format and contribution flow.
