# frozen_string_literal: true

# While the hybrid format is selected, show the Markdown syntax help
# (new content is expected to be written in Markdown).
module TextileTransparent
  module HelpControllerPatch
    def show_wiki_syntax
      if Setting.text_formatting == 'hybrid'
        markdown = TextileTransparent::TextileSniffer.markdown_format
        type = params[:type].nil? ? "" : "#{params[:type]}_"
        lang = current_language.to_s.downcase
        template = "help/wiki_syntax/#{markdown}/#{lang}/wiki_syntax_#{type}#{markdown}"
        lang = "en" unless lookup_context.exists?(template)
        render template: "help/wiki_syntax/#{markdown}/#{lang}/wiki_syntax_#{type}#{markdown}", layout: nil
      else
        super
      end
    end
  end
end
