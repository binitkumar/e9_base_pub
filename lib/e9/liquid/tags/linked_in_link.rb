module E9::Liquid::Tags
  class LinkedInLink< Base
    class << self
      def title
        "LinkedIn Link"
      end

      def description
        "Link to your LinkedIn page"
      end

      def tag_name
        "linked_in_link"
      end
    end

    def render!
      view_send :linked_in_company_page_link
    end
  end

  Liquid::Template.register_tag(LinkedInLink.tag_name, LinkedInLink)
end

