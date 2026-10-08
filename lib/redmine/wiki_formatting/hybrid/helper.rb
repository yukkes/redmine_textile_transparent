# frozen_string_literal: true

# Editor helper for the hybrid format.
# New content is written in Markdown, so the toolbar, preview help link and
# initial wiki page content all delegate to the Markdown (common_mark) helper.
module Redmine
  module WikiFormatting
    module Hybrid
      module Helper
        def wikitoolbar_for(field_id, preview_url = preview_text_path)
          markdown_helper(:wikitoolbar_for, field_id, preview_url)
        end

        def heads_for_wiki_formatter
          markdown_helper(:heads_for_wiki_formatter)
        end

        def initial_page_content(page)
          markdown_helper(:initial_page_content, page)
        end

        private

        def markdown_helper(method_name, *args)
          helper = Redmine::WikiFormatting.helper_for(
            TextileTransparent::TextileSniffer.markdown_format
          )
          if helper.instance_methods.include?(method_name) ||
             helper.methods.include?(method_name)
            extend helper
            send(method_name, *args)
          else
            super()
          end
        end
      end
    end
  end
end
