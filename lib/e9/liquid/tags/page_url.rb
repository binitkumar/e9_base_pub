module E9::Liquid::Tags
  class PageUrl < Base
    class << self
      def title
        "Page URL"
      end

      def description
        "The URL of the current page"
      end

      def tag_name
        "page_url"
      end
    end

    def render!
      context['page'].try(:url)
    end
  end
  
  Liquid::Template.register_tag(PageUrl.tag_name, PageUrl)
end
