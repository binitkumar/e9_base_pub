module E9::Liquid::Tags
  class RecipientUnsubscribePath < Base
    class << self
      def title
        "Recipient Unsubscribe Path"
      end

      def description
        "The relative path to a user's unsubscribe page"
      end

      def tag_name
        "recipient_unsubscribe_path"
      end
    end

    def render!
      context['subscription'].try(:unsubscribe_path)
    end
  end
  
  Liquid::Template.register_tag(RecipientUnsubscribePath.tag_name, RecipientUnsubscribePath)
end
