module E9::Liquid::Tags
  class RecipientUnsubscribeUrl < Base
    class << self
      def title
        "Recipient Unsubscribe URL"
      end

      def description
        "The absolute url to a user's unsubscribe page"
      end

      def tag_name
        "recipient_unsubscribe_url"
      end
    end

    def render!
      context['subscription'].try(:unsubscribe_url)
    end
  end
  
  Liquid::Template.register_tag(RecipientUnsubscribeUrl.tag_name, RecipientUnsubscribeUrl)
end
