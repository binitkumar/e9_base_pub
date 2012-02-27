require 'action_view/helpers/text_helper'
require 'action_controller/vendor/html-scanner'
require 'liquid'

module E9
  module HTML
    extend ActiveSupport::Concern
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper

    EncodedString = /\s*&[^;]{1,5};\s*/

    module ClassMethods
      def white_list_sanitizer
        @white_list_sanitizer ||= ::HTML::WhiteListSanitizer.new
      end

      def full_sanitizer
        @full_sanitizer ||= ::HTML::FullSanitizer.new
      end

      def html_strip(html)
        html.gsub(EncodedString, ' ')
      end

      def liquid_strip(string)
        string.gsub(::Liquid::TemplateParser, ' ')
      end

      def full_sanitize_and_strip(string)
        liquid_strip(html_strip(full_sanitizer.sanitize(string)))
      end

      def sanitize_and_strip(string)
        liquid_strip(html_strip(white_list_sanitizer.sanitize(string)))
      end
    end
  end
end
