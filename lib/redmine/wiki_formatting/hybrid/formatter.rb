# frozen_string_literal: true

require 'digest/md5'

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
        def initialize(text, options = {})
          @text = text
          @options = options || {}
        end

        def to_html(*args)
          delegate_formatter.to_html(*args)
        end

        # Section editing is delegated as well, so that Textile texts are split
        # at Textile headings. Redmine 5.0's Markdown formatter has no section
        # support; the whole text is then edited as a single section.
        def get_section(index)
          formatter = delegate_formatter
          return formatter.get_section(index) if formatter.respond_to?(:get_section)

          [@text.to_s, Digest::MD5.hexdigest(@text.to_s)]
        end

        def update_section(index, update, hash = nil)
          formatter = delegate_formatter
          return formatter.update_section(index, update, hash) if formatter.respond_to?(:update_section)

          raise Redmine::WikiFormatting::StaleSectionError if hash.present? && hash != get_section(index)[1]

          update
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
