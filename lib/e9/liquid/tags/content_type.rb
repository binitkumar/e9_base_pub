module E9::Liquid::Tags
  class ContentType < Base
    class << self
      def title
        "Content Type"
      end

      def description
        "The content type of the current record (page, blog post, etc.)"
      end

      def tag_name
        "content_type"
      end
    end

    def render!
      context['page'].try(:content_type)
    end
  end
  
  Liquid::Template.register_tag(ContentType.tag_name, ContentType)
end
