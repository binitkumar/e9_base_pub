require 'liquid'

module E9
  module Renderers
    module Liquid

      # Render with local vars:
      # Should accept locals hash in form of { "var" => "val" } and return rendered string
      def render(locals = {}, refresh_cached_parser = true)
        raise ArgumentError, "#{self.class} should implement #template to return liquid template" unless respond_to?(:template)
        _render(template, locals)
      end
      alias_method :to_s, :render

      private
      
      def _render(template_body, locals, refresh_cached_parser = true)
        clear_cached_parser if refresh_cached_parser
        cached_parser(template_body).render(locals)
      end

      def clear_cached_parser
        @parser = nil
      end

      def cached_parser(template_body)
        @parser ||= ::Liquid::Template.parse(template_body)
      end
    end
  end
end
