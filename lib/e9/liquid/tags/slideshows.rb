module E9::Liquid::Tags
  class Slideshows < Block
    class << self
      def title
        "Slideshows"
      end

      def description
        "Iterate over slideshow records"
      end

      def tag_name
        "slideshows"
      end
    end

    def render!
      @context = context

      context['config'].try(:site_domain)
    end
  end

  Liquid::Template.register_tag(Slideshows.tag_name, Slideshows)
end
