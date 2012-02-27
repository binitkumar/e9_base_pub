module E9::Liquid::Tags
  class Title < Base
    class << self
      def title
        "Title"
      end

      def description
        "The title of the current page or record (blog post, topic, etc.)"
      end

      def tag_name
        "title"
      end
    end

    def render!
      context['page'].try(:title)
    end
  end
  
  Liquid::Template.register_tag(Title.tag_name, Title)
end
