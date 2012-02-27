require 'liquid'
require 'action_view/helpers/text_helper'

module E9::Social
  module Clients
    extend ActiveSupport::Concern
    include ActionView::Helpers::TextHelper

    included do
      class_inheritable_accessor :_social_update_methods
      self._social_update_methods = []

      include Twitter
      include Facebook
    end

    def social_update!
      self.class.read_inheritable_attribute(:_social_update_methods).each do |method|
        send(method)
      end
    end

    def _process_liquid_comment(comment, opts = {})
      return '' if comment.blank?
      opts.reverse_merge!(:render => true)
      comment = liquify_comment(comment) if opts[:render]
      comment = truncate(comment, :length => opts[:length]) if opts[:length]
      comment = liquify_comment("#{comment || ''} - {{ page.url #{'|  bitly' if opts[:bitly] }}}") if opts[:append_link]
      comment
    end

    def liquid_env
      @_liquid_env ||= ::E9::Liquid::Env.new.merge('page' => self, 'user' => author)
    end

    def liquify_comment(comment)
      return comment unless comment =~ ::Liquid::TemplateParser
      ::Liquid::Template.parse(comment).render(liquid_env)
    end
  end
end
