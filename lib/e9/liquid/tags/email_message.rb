module E9::Liquid::Tags
  class EmailMessage < Base
    class << self
      def title
        "Email Message"
      end

      def description
        "The body of the current email"
      end

      def tag_name
        "email_message"
      end
    end

    def render!
      context['email'].try(:message)
    end
  end
  
  Liquid::Template.register_tag(EmailMessage.tag_name, EmailMessage)
end
