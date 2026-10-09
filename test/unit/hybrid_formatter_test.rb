# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class HybridFormatterTest < ActiveSupport::TestCase
  def test_registers_hybrid_format
    assert_includes Redmine::WikiFormatting.format_names, 'hybrid'
    assert_equal Redmine::WikiFormatting::Hybrid::Formatter,
                 Redmine::WikiFormatting.formatter_for('hybrid')
    assert_equal Redmine::WikiFormatting::Hybrid::Helper,
                 Redmine::WikiFormatting.helper_for('hybrid')
  end

  def test_renders_textile_with_textile_formatter
    html = to_html("h1. Title\n\n*bold* and _em_")

    assert_match %r{<h1[^>]*>Title</h1>}, html
    assert_match %r{<strong>bold</strong>}, html
  end

  def test_renders_markdown_with_common_mark_formatter
    html = to_html("# Title\n\n**bold** and [link](https://www.redmine.org/)")

    assert_match %r{<h1[^>]*>Title</h1>}, html
    assert_match %r{<strong>bold</strong>}, html
    assert_match %r{<a href="https://www.redmine.org/"}, html
  end

  def test_output_matches_delegated_formatter
    textile = 'h2. Section'
    markdown = '## Section'

    assert_equal formatter('textile').new(textile).to_html, to_html(textile)
    assert_equal formatter('common_mark').new(markdown).to_html, to_html(markdown)
  end

  def test_edits_textile_sections
    text = "h1. One\n\nfoo\n\nh1. Two\n\nbar"
    section, hash = hybrid(text).get_section(2)

    assert_equal "h1. Two\n\nbar", section
    assert_equal "h1. One\n\nfoo\n\nh1. Two\n\nbaz", hybrid(text).update_section(2, "h1. Two\n\nbaz", hash)
  end

  def test_edits_markdown_sections
    text = "# One\n\nfoo\n\n# Two\n\nbar"
    section, hash = hybrid(text).get_section(2)
    updated = hybrid(text).update_section(2, "# Two\n\nbaz", hash)

    if formatter('common_mark').method_defined?(:update_section)
      assert_equal "# Two\n\nbar", section
      assert_equal "# One\n\nfoo\n\n# Two\n\nbaz", updated
    else
      # Redmine 5.0: no Markdown section support, the whole text is edited.
      assert_equal text, section
      assert_equal "# Two\n\nbaz", updated
    end
  end

  def test_rejects_stale_section_update
    assert_raises Redmine::WikiFormatting::StaleSectionError do
      hybrid("h1. One\n\nfoo").update_section(1, "h1. One\n\nbar", 'stale')
    end
    assert_raises Redmine::WikiFormatting::StaleSectionError do
      hybrid("# One\n\nfoo").update_section(1, "# One\n\nbar", 'stale')
    end
  end

  private

  def formatter(name)
    Redmine::WikiFormatting.formatter_for(name)
  end

  def hybrid(text)
    formatter('hybrid').new(text)
  end

  def to_html(text)
    hybrid(text).to_html
  end
end
