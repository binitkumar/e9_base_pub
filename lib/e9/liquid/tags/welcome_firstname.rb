module E9::Liquid::Tags
  class WelcomeFirstname < Base
    class << self
      def title
        "Welcome First Name Widget"
      end

      def description
        "Welcome the current user by first name"
      end

      def tag_name
        "welcome_firstname"
      end
    end

    def render!
      if u = context['user']
        "Welcome #{u.first_name}"
      else
        ''
      end
    end
  end
  
  Liquid::Template.register_tag(WelcomeFirstname.tag_name, WelcomeFirstname)
end
