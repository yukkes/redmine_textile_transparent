# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :redmine_textile_transparent do
  name 'Redmine Textile Transparent'
  author 'yukkes'
  description 'Adds a "Hybrid" text formatting option that renders existing Textile ' \
              'content with Redmine\'s built-in Textile formatter and new Markdown ' \
              'content with the built-in Markdown formatter. No data conversion ' \
              'and no extra tables are required.'
  version '0.1.0'
  url 'https://github.com/yukkes/redmine_textile_transparent'
  author_url 'https://github.com/yukkes'
  requires_redmine version_or_higher: '5.0.0'
end

base = File.dirname(__FILE__)

require File.join(base, 'lib', 'textile_transparent', 'textile_sniffer')
require File.join(base, 'lib', 'redmine', 'wiki_formatting', 'hybrid', 'formatter')
require File.join(base, 'lib', 'redmine', 'wiki_formatting', 'hybrid', 'helper')

# The built-in formats (textile / common_mark) are registered during
# Redmine::Preparation, which runs in the application initializer. Register
# the hybrid format after initialization so that it lands in the same
# registry and appears in the settings select box.
Rails.application.config.after_initialize do
  Redmine::WikiFormatting.register(
    :hybrid,
    Redmine::WikiFormatting::Hybrid::Formatter,
    Redmine::WikiFormatting::Hybrid::Helper,
    nil,
    label: 'Hybrid (Textile + Markdown)'
  )
end

# Redmine runs each plugin's init.rb from a to_prepare callback, so the
# patches below are (re)applied whenever the application is prepared.

# Markdown syntax help while hybrid is selected. Redmine 5.x serves the
# syntax help as static files linked from the (Markdown) toolbar instead.
if Object.const_defined?(:HelpController)
  require File.join(base, 'lib', 'textile_transparent', 'help_controller_patch')
  unless HelpController.included_modules.include?(TextileTransparent::HelpControllerPatch)
    HelpController.prepend TextileTransparent::HelpControllerPatch
  end
end

# Quote button should emit Markdown while hybrid is selected.
if defined?(Redmine::QuoteReply::Helper)
  require File.join(base, 'lib', 'textile_transparent', 'quote_reply_helper_patch')
  unless Redmine::QuoteReply::Helper.included_modules.include?(TextileTransparent::QuoteReplyHelperPatch)
    Redmine::QuoteReply::Helper.prepend TextileTransparent::QuoteReplyHelperPatch
  end
end
