# frozen_string_literal: true

# A delegating formatter registered as "hybrid".
#
# Each text is sniffed: texts containing Textile markup are rendered by
# Redmine's built-in Textile formatter, everything else by the built-in
# Markdown (common_mark) formatter. All rendering is done by Redmine core;
# this class only decides which one to delegate to.
module Redmine
  module WikiFormatting
    module Hybrid
      class Formatter
        include Redmine::WikiFormatting::SectionHelper

        def initialize(text, options = {})
          @text = text
          @options = options || {}
        end

        def to_html(*args)
          delegate_formatter.to_html(*args)
        end

        def update_section(index, update, hash = nil)
          delegate_formatter.update_section(index, update, hash)
        end

        private

        # Redmine 5.x/6.x formatters take initialize(text);
        # Redmine 7.x takes initialize(text, options = {}).
        def delegate_formatter
          if formatter_class.instance_method(:initialize).arity == 1
            formatter_class.new(@text)
          else
            formatter_class.new(@text, @options)
          end
        end

        def formatter_class
          Redmine::WikiFormatting.formatter_for(
            TextileTransparent::TextileSniffer.format_for(@text)
          )
        end
      end
    end
  end
end
