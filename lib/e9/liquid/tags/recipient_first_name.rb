module E9::Liquid::Tags
  class RecipientFirstName < Base
    class << self
      def title
        "Recipient First Name"
      end

      def description
        "The first name of the recipient of this email"
      end

      def tag_name
        "recipient_first_name"
      end
    end

    def render!
      context['recipient'].try(:first_name)
    end
  end
  
  Liquid::Template.register_tag(RecipientFirstName.tag_name, RecipientFirstName)
end
