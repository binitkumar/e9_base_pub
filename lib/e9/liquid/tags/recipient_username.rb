module E9::Liquid::Tags
  class RecipientUsername < Base
    class << self
      def title
        "Recipient Username"
      end

      def description
        "The website username of the recipient of this email"
      end

      def tag_name
        "recipient_username"
      end
    end

    def render!
      context['recipient'].try(:username)
    end
  end
  
  Liquid::Template.register_tag(RecipientUsername.tag_name, RecipientUsername)
end
