module E9::Liquid::Tags
  class RecipientEmailAddress < Base
    class << self
      def title
        "Recipient Email Address"
      end

      def description
        "The email address of the recipient of this email"
      end

      def tag_name
        "recipient_email_address"
      end
    end

    def render!
      context['recipient'].try(:email)
    end
  end
  
  Liquid::Template.register_tag(RecipientEmailAddress.tag_name, RecipientEmailAddress)
end
