module E9::Liquid::Tags
  class RecipientResetAccountUrl < Base
    class << self
      def title
        "Recipient Reset Password URL"
      end

      def description
        "A link to allow the recipient of this email to reset their account password"
      end

      def tag_name
        "recipient_reset_password_url"
      end
    end

    def render!
      context['recipient'].try(:reset_password_url)
    end
  end
  
  Liquid::Template.register_tag(RecipientResetAccountUrl.tag_name, RecipientResetAccountUrl)
end
