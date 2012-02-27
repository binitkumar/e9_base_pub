module E9::Liquid::Tags
  class LinkTo < Base
    HasArg = /^(\S+\b)\s*([^\s\[]|$)/

    class << self
      def title
        "Link To"
      end

      def description
        "Create an HTML Link"
      end

      def tag_name
        "link_to"
      end
    end

    def initialize(tag_name, markup, tokens)
      if HasArg =~ markup
        @target = $1
      end
      
      super
    end

    def render!
      if @target.present?
        if obj = case @target
                 when /^(http:|www|mailto)(.*)$/
                   @target = "http://#{@target}" if $1 == 'www'
                   @target
                 when /^\w+_(url|path)\Z/
                   controller_send(@target) rescue nil
                 when 'page'
                   context['page']
                 when 'next_record'
                   context['page'].try(:next_record)
                 when 'previous_record'
                   context['page'].try(:previous_record)
                 end

          if String === obj
            obj = Struct.new(:url, :context).new(obj)
          end
          
          # this apparently is a bug where the drop doesn't
          # have a context outside the template
          obj.context = context

          @attributes.reverse_merge!(:href => obj.url)
          
          text = if obj.respond_to?(:thumb_url) && E9.true_value?(@attributes.delete(:thumb))
            %Q[<img src="#{obj.thumb_url}" title="#{CGI.escapeHTML(obj.title)}"/>]
          elsif obj.respond_to?(:title)
            obj.title
          else
            obj.url
          end

          @attributes.reverse_merge!(:text => text)
          
          if @target == 'next_record'
            @attributes.reverse_merge!(:rel => "next")
          elsif @target == 'previous_record'
            @attributes.reverse_merge!(:rel => "prev")
          end
        else
          # if an object was passed and not found, return
          # nothing
          return nil
        end
      end

      text = @attributes.delete(:text)
      href = @attributes.delete(:href)

      view_send(:link_to, text.html_safe, href, @attributes)
    end
  rescue => e
    Rails.logger("link_to tag: #{e}")
  end

  Liquid::Template.register_tag(LinkTo.tag_name, LinkTo)
end
