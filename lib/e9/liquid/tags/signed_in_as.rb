module E9::Liquid::Tags
  class SignedInAs < Base
    class << self
      def title
        "Signed in as Username Widget"
      end

      def description
        "Notify the current user they are signed in."
      end

      def tag_name
        "signed_in_as_username"
      end
    end

    def render!
      if u = context['current_user']
        "Signed in as #{u['username']}"
      else
        ''
      end
    end
  end

  Liquid::Template.register_tag(SignedInAs.tag_name, SignedInAs)
end
