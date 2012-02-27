module E9::Liquid::Tags
  class PageTitle < Base
    class << self
      def title
        "Page Title"
      end

      def description
        "The title of the current page"
      end

      def tag_name
        "page_title"
      end
    end

    def render!
      context['page'].try(:title)
    end
  end
  
  Liquid::Template.register_tag(PageTitle.tag_name, PageTitle)
end
