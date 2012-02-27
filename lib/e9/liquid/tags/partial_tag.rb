module E9::Liquid::Tags
  class PartialTag < Base
    Param = /(\w+)/
    Opts  = /(\w+\/\w+)\s*/

    class << self
      def title
        "Partial Tag"
      end

      def description
        "Render a Partial"
      end

      def tag_name
        "partial"
      end
    end

    def initialize(tag_name, markup, tokens)
      super(tag_name, markup, tokens)

      if markup =~ Param
        @partial_name = $1
      end
      
      @options = {}
      markup.scan(Opts).each do |match|
        key, val = match.first.split('/')
        @options[key.to_sym] = val
      end
    end

    def render!
      render_partial("partials/#{@partial_name}", @options) if @partial_name
    end
  end

  Liquid::Template.register_tag(PartialTag.tag_name, PartialTag)
end
