module E9::Liquid::Tags
  class SiteName < Base
    class << self
      def title
        "Site Name"
      end

      def description
        "The name of this website"
      end

      def tag_name
        "site_name"
      end
    end

    def render!
      context['config'].try(:site_name)
    end
  end
  
  Liquid::Template.register_tag(SiteName.tag_name, SiteName)
end
