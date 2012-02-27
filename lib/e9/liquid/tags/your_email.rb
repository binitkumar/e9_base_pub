module E9::Liquid::Tags
  class YourEmail < Base
    class << self
      def title
        "Your Email"
      end

      def description
        "Your email address associated with this account"
      end

      def tag_name
        "your_email"
      end
    end

    def render!
      context['sender'].try(:email)
    end
  end
  
  Liquid::Template.register_tag(YourEmail.tag_name, YourEmail)
end
