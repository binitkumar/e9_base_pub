module E9::Liquid::Tags
  class Helper < Base
    class << self
      def title
        "Helper"
      end

      def description
        "Call an existing view helper (note that only methods with string arguments are supported)"
      end

      def tag_name
        "helper"
      end
    end

    def initialize(tag_name, markup, tokens)
      @method, *@arguments = markup.scan(/\w+/)

      super
    end

    def render!
      args  = [@method]
      args += @arguments if @arguments.present?

      view_send(*args)
    end
  end

  Liquid::Template.register_tag(Helper.tag_name, Helper)
end
