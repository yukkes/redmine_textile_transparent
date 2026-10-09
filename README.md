# redmine_textile_transparent

[![tests](https://github.com/yukkes/redmine_textile_transparent/actions/workflows/tests.yml/badge.svg)](https://github.com/yukkes/redmine_textile_transparent/actions/workflows/tests.yml)
[![Redmine](https://img.shields.io/badge/Redmine-5.0%20%7C%205.1%20%7C%206.0%20%7C%206.1%20%7C%207.0-B32024?logo=redmine)](https://www.redmine.org/)
[![Code style: RuboCop](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A Redmine plugin that adds a **Hybrid** text formatting option.

Existing Textile content is rendered by Redmine's built-in Textile formatter,
while new Markdown content is rendered by the built-in CommonMark (GitHub
Flavored) formatter — transparently, per text, with **no data migration, no
extra tables and no core patching**.

- Redmine 5.0 / 5.1 / 6.0 / 6.1 / 7.0
- Select *Administration → Settings → General → Text formatting →
  “Hybrid (Textile + Markdown)”*
- Toolbars, syntax help, preview and quote button use Markdown, so all new
  input is written in Markdown.

## How it works

`Setting.text_formatting` selects a formatter by name. This plugin registers
`hybrid` as a first-class format:

```
Setting.text_formatting = 'hybrid'
        ↓
formatter('hybrid').new(text).to_html   # plugin's delegating formatter
        ↓
Textile syntax detected? →  Redmine's built-in Textile formatter
         otherwise       →  Redmine's built-in common_mark formatter
```

Detection uses a Textile-syntax sniffer (`h1.`, `"text":url`, `!image!`,
`|_.`, `%{style}%`, `<notextile>`, weak signals `*bold*`, `_em_`, `-del-`,
`+ins+`, `^sup^`, `~sub~`). `{{macro}}`, `#123`, `r123` are common to both
formats and never used for detection.

## Install

```bash
cd /path/to/redmine/plugins
git clone https://github.com/yukkes/redmine_textile_transparent.git
# restart Redmine
```

Then choose **Hybrid** in *Settings → General → Text formatting*.

## Tests

Tests run in Docker against the official `redmine` image:

```bash
bin/build --build-arg REDMINE_VERSION=7.0   # 5.0 / 5.1 / 6.0 / 6.1 / 7.0
bin/test
```

GitHub Actions runs RuboCop, Brakeman and the test suite against
Redmine 5.0, 5.1, 6.0, 6.1 and 7.0 on every push to `main` and on pull
requests.
