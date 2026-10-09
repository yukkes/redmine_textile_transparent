# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

# HelpController exists since Redmine 6.0 (5.x serves static help files).
return unless Object.const_defined?(:HelpController)

class HelpControllerTest < Redmine::ControllerTest
  tests HelpController

  def test_shows_markdown_syntax_help_when_hybrid_is_selected
    assert_equal wiki_syntax('common_mark'), wiki_syntax('hybrid')
    assert_not_equal wiki_syntax('textile'), wiki_syntax('hybrid')
  end

  def test_shows_detailed_markdown_syntax_help_when_hybrid_is_selected
    assert_equal wiki_syntax('common_mark', type: 'detailed'), wiki_syntax('hybrid', type: 'detailed')
  end

  private

  def wiki_syntax(text_formatting, params = {})
    with_settings text_formatting: text_formatting do
      get :show_wiki_syntax, params: params
      assert_response :success
      response.body
    end
  end
end
