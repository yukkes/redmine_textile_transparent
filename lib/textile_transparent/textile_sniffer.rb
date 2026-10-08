# frozen_string_literal: true

# Detects whether a text was written in Textile markup.
#
# Strong signals (a single match is enough):
#   h1. headings, bq. / bc. / p. blocks, "link":url, !image!,
#   |_. table headers, %{style}span%, <notextile>, fn1.
#
# Weak signals (ambiguous with Markdown, require >= 2 hits):
#   *bold*, _em_, -del-, +ins+, ^sup^, ~sub~
module TextileTransparent
  module TextileSniffer
    STRONG_PATTERNS = [
      /^[ \t]*h[1-6]\.\s/,                              # h1. Heading
      /^[ \t]*(?:bq|bc|p)\.\s/,                          # bq. bc. p.
      /"[^"\n]+":(?:https?|ftp|mailto):\/\//,            # "text":http://...
      /"[^"\n]+":\//,                                    # "text":/local/path
      /(?<![!\w])!(?!\[)[^\s!][^!\n]*!(?!\w)/,           # !image.png! (not ![alt](url))
      /^\|[_.<>=~^{\\][^|\n]*\|/,                        # |_. header | cell with attrs
      /(?<!\w)%\{[^}\n]+\}[^%\n]*%(?!\w)/,               # %{style}text%
      /^fn\d+\.\s/,                                      # fn1. footnote
    ].freeze

    WEAK_PATTERNS = [
      /(?<!\*)\*[^\s*][^*\n]*\*(?!\*)/,                  # *bold*  (not **bold**)
      /(?<!\w)_[^\s_][^_\n]*_(?!\w)/,                    # _em_
      /(?<!\w)-[^\s-][^-\n]*-(?!\w)/,                    # -deleted-
      /(?<!\w)\+[^\s+][^+\n]*\+(?!\w)/,                  # +inserted+
      /(?<!\w)\^[^\s^\n]+\^(?!\w)/,                      # ^sup^
      /(?<![~\w])~[^~\s][^~\n]*~(?![~\w])/,              # ~sub~ (not ~~strike~~)
    ].freeze

    # Regions that must not be scanned for markup signals.
    # <notextile> itself IS a strong textile signal, so it is handled
    # separately before stripping.
    STRIP_PATTERNS = [
      /^[ \t]*(```|~~~).*?^[ \t]*\1/m,                   # markdown fenced code
      %r{<pre[^>]*>.*?</pre>}mi,                         # textile/html <pre>
      %r{<code[^>]*>.*?</code>}mi,                       # inline code block
      /`[^`\n]+`/,                                       # markdown inline code
      %r{@"[^"\n]+"}m,                                   # textile @code@
    ].freeze

    NOTEXTILE_RE = %r{<notextile>}i

    class << self
      # Returns true if the text looks like it was written in Textile.
      def textile?(text)
        return false if text.nil?
        raw = text.to_s
        return true if raw =~ NOTEXTILE_RE

        body = strip_ignored_regions(raw.gsub(%r{<notextile>.*?</notextile>}mi, ' '))

        return true if STRONG_PATTERNS.any? { |re| body =~ re }

        WEAK_PATTERNS.count { |re| body =~ re } >= 2
      end

      # Format name that should render the text under the hybrid formatter.
      def format_for(text)
        textile?(text) ? 'textile' : markdown_format
      end

      # The Markdown engine available in this Redmine version.
      def markdown_format
        if Redmine::WikiFormatting.format_names.include?('common_mark')
          'common_mark'
        else
          'markdown'
        end
      end

      private

      def strip_ignored_regions(text)
        STRIP_PATTERNS.reduce(text) { |t, re| t.gsub(re, ' ') }
      end
    end
  end
end
