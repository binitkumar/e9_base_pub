module E9::Liquid::Tags
  class FacebookLink < Base
    class << self
      def title
        "Facebook Link"
      end

      def description
        "Link to your facebook page"
      end

      def tag_name
        "facebook_link"
      end
    end

    def render!
      view_send :facebook_company_page_link
    end
  end

  Liquid::Template.register_tag(FacebookLink.tag_name, FacebookLink)
end

