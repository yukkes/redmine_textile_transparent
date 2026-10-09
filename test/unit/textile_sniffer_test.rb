# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TextileSnifferTest < ActiveSupport::TestCase
  def test_detects_strong_textile_signals
    [
      'h1. Heading',
      'bq. Quote',
      'See "Redmine":https://www.redmine.org/',
      'See "Wiki":/projects/foo/wiki',
      '!image.png!',
      '|_. Header |_. Header |',
      '%{color:red}red%',
      'fn1. Footnote',
      '<notextile>*raw*</notextile>'
    ].each do |text|
      assert textile?(text), "expected Textile: #{text.inspect}"
    end
  end

  def test_requires_two_weak_textile_signals
    assert textile?('*bold* and _em_')
    assert_not textile?('*bold* only')
  end

  def test_treats_markdown_as_markdown
    [
      '# Heading',
      '**bold** and _em_',
      '[Redmine](https://www.redmine.org/)',
      '![alt](image.png)',
      "| a | b |\n|---|---|\n| 1 | 2 |",
      '~~strike~~ and *em*'
    ].each do |text|
      assert_not textile?(text), "expected Markdown: #{text.inspect}"
    end
  end

  def test_ignores_markup_inside_code
    assert_not textile?("```\nh1. not a heading\n```")
    assert_not textile?('Use `h1. Title` for headings')
    assert_not textile?("<pre>\nh1. not a heading\n</pre>")
  end

  def test_ignores_syntax_common_to_both_formats
    assert_not textile?('See #123, r456 and {{toc}}')
  end

  def test_handles_nil_and_empty_text
    assert_not textile?(nil)
    assert_not textile?('')
  end

  def test_format_for
    assert_equal 'textile', TextileTransparent::TextileSniffer.format_for('h1. Heading')
    assert_equal 'common_mark', TextileTransparent::TextileSniffer.format_for('# Heading')
  end

  private

  def textile?(text)
    TextileTransparent::TextileSniffer.textile?(text)
  end
end
