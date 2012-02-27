module E9::Liquid::Tags
  class LastName < Base
    class << self
      def title
        "Last Name Widget"
      end

      def description
        "The last name of the current user"
      end

      def tag_name
        "last_name"
      end
    end

    def render!
      context['user'].try(:last_name) rescue ''
    end
  end

  Liquid::Template.register_tag(LastName.tag_name, LastName)
end
