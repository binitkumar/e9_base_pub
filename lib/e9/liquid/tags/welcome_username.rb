module E9::Liquid::Tags
  class WelcomeUsername < Base
    class << self
      def title
        "Welcome Username Widget"
      end

      def description
        "Welcome the current user by username."
      end

      def tag_name
        "welcome_username"
      end
    end

    def render!
      if u = context['user']
        "Welcome #{u.username}"
      else
        ''
      end
    end
  end

  Liquid::Template.register_tag(WelcomeUsername.tag_name, WelcomeUsername)
end

