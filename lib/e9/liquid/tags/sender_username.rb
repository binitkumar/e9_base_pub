module E9::Liquid::Tags
  class SenderUsername < Base
    class << self
      def title
        "Sender Username"
      end

      def description
        "The username of the individual who initiated this action"
      end

      def tag_name
        "sender_username"
      end
    end

    def render!
      context['sender'].try(:username)
    end
  end
  
  Liquid::Template.register_tag(SenderUsername.tag_name, SenderUsername)
end
