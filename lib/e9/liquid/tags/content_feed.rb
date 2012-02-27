module E9::Liquid::Tags
  class ContentFeed < Feed
    class << self
      def partial; 'shared/liquid_tags/content_feed' end
      def title; "Content Feed Widget" end
      def description; "Insert custom content feeds" end
      def tag_name; "content_feed" end
    end
  end

  Liquid::Template.register_tag(ContentFeed.tag_name, ContentFeed)
end
