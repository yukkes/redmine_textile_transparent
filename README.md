# redmine_textile_transparent

A Redmine plugin that adds a **Hybrid** text formatting option.

Existing Textile content is rendered by Redmine's built-in Textile formatter,
while new Markdown content is rendered by the built-in CommonMark (GitHub
Flavored) formatter — transparently, per text, with **no data migration, no
extra tables and no core patching**.

- Redmine 5 / 6 / 7
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

## Tested on

Redmine 5.1 / 6.1 / 7.0 (Docker `redmine:5.1`, `redmine:6.1`, `redmine:7.0`)
— formatter unit tests and Playwright browser tests all pass.
