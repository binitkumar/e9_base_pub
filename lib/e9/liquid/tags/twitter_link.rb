module E9::Liquid::Tags
  class TwitterLink< Base
    class << self
      def title
        "Twitter Link"
      end

      def description
        "Link to your Twitter page"
      end

      def tag_name
        "twitter_link"
      end
    end

    def render!
      view_send :twitter_company_page_link
    end
  end

  Liquid::Template.register_tag(TwitterLink.tag_name, TwitterLink)
end

