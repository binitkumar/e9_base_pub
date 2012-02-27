module E9::Liquid::Tags
  class RecipientResetAccountPath < Base
    class << self
      def title
        "Recipient Reset Password Path"
      end

      def description
        "A link to allow the recipient of this email to reset their account password"
      end

      def tag_name
        "recipient_reset_password_path"
      end
    end

    def render!
      context['recipient'].try(:reset_password_path)
    end
  end
  
  Liquid::Template.register_tag(RecipientResetAccountPath.tag_name, RecipientResetAccountPath)
end
