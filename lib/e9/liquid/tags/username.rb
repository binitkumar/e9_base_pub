module E9::Liquid::Tags
  class Username < Base
    class << self
      def title
        "Username Widget"
      end

      def description
        "The username of the current user"
      end

      def tag_name
        "username"
      end
    end

    def render!
      context['user'].try(:username) rescue ''
    end
  end

  Liquid::Template.register_tag(Username.tag_name, Username)
end
