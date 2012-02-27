module E9::Liquid::Tags
  class FirstName < Base
    class << self
      def title
        "First Name Widget"
      end

      def description
        "The first name of the current user"
      end

      def tag_name
        "first_name"
      end
    end

    def render!
      context['user'].try(:first_name) rescue ''
    end
  end

  Liquid::Template.register_tag(FirstName.tag_name, FirstName)
end
