module E9::Liquid::Tags
  class SiteDomain < Base
    class << self
      def title
        "Site Domain"
      end

      def description
        "The domain of this website"
      end

      def tag_name
        "site_domain"
      end
    end

    def render!
      context['config'].try(:site_domain)
    end
  end
  
  Liquid::Template.register_tag(SiteDomain.tag_name, SiteDomain)
end
