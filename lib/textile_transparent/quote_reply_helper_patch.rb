# frozen_string_literal: true

# Tell the JS quote formatter to use the Markdown conversion while the
# hybrid format is selected (quoted text is inserted into a Markdown editor).
module TextileTransparent
  module QuoteReplyHelperPatch
    def quote_reply_button(url:, icon_only: false)
      if Setting.text_formatting == 'hybrid'
        markdown = TextileTransparent::TextileSniffer.markdown_format
        button_params = {
          data: {
            action: 'quote-reply#quote',
            quote_reply_url_param: url,
            quote_reply_text_formatting_param: markdown
          },
          class: "#{icon_only ? 'icon-only' : 'icon'} icon-quote"
        }
        button_params[:title] = l(:button_quote) if icon_only

        link_to sprite_icon('quote-filled', l(:button_quote), icon_only: icon_only, style: :filled),
                '#', button_params
      else
        super
      end
    end
  end
end
