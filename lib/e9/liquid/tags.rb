module E9::Liquid::Tags
  class Base < ::Liquid::Tag
    class << self
      def tag_name;    ''                  end
      def title;       ''                  end
      def description; ''                  end
      def to_param;    tag_name            end
      def to_s;        "{% #{tag_name} %}" end
    end

    attr_reader :context
    class_inheritable_accessor :array_attributes

    self.array_attributes = [
      :labels, :tags, :content_type, :role, :display, :hide,
      :blog_name, :blog, :blog_id,
      :forum_name, :forum, :forum_id, 
      :content_name, :name, :content_id,
      :faq_name, :faq, :faq_id,
      :slideshow, :slideshow_name, :slideshow_id
    ] 

    # 
    # only attributes in Base.array_attributes will be parsed as arrays
    # otherwise it will take the first value if an array is passed.
    #
    # TODO do away with this convention, as it leads to errors that are hard to diagnose
    #
    def initialize(tag_name, markup, tokens)
      self.array_attributes ||= []
      @attributes = Hash.new

      markup.scan(E9::Liquid::TagAttributes) do |key, value|
        parsed = value.split('|').delete_if(&:blank?).map(&:strip)

        unless parsed.blank? 
          k = key.underscore.to_sym
          @attributes[k] = self.array_attributes.include?(k) ? parsed : parsed.first
        end
      end

      super
    end

    #
    # subclasses should implement render! as opposed to the typical render
    #
    def render!; raise NotImplementedError end

    def render(context)
      @context = context

      render! || '' # safely return an empty string if render! is nil
    end

    def controller;             context.registers[:controller] end
    def controller_send(*args); controller.try(:send, *args)   end

    def view;                   context.registers[:view] || controller.try(:view_context) end
    def view_send(*args);       view.try(:send, *args)         end

    def render_partial(partial, locals = {})
      view_send(:render, :partial => partial, :locals => locals)
    end
  end

  class Block < Base
    IsTag = /^#{E9::Liquid::TagStart}/
    IsVariable = /^#{E9::Liquid::VariableStart}/
    FullToken = /^#{E9::Liquid::TagStart}\s*(\w+)\s*(.*)?#{E9::Liquid::TagEnd}$/
    ContentOfVariable = /^#{E9::Liquid::VariableStart}(.*)#{E9::Liquid::VariableEnd}$/

    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear

      while token = tokens.shift

        case token
        when IsTag
          if token =~ FullToken

            # if we found the proper block delimitor just end parsing here and let the outer block
            # proceed
            if block_delimiter == $1
              end_tag
              return
            end

            # fetch the tag from registered blocks
            if tag = Template.tags[$1]
              @nodelist << tag.new($1, $2, tokens)
            else
              # this tag is not registered with the system
              # pass it to the current block for special handling or error reporting
              unknown_tag($1, $2, tokens)
            end
          else
            raise SyntaxError, "Tag '#{token}' was not properly terminated with regexp: #{TagEnd.inspect} "
          end
        when IsVariable
          @nodelist << create_variable(token)
        when ''
          # pass
        else
          @nodelist << token
        end
      end

      # Make sure that its ok to end parsing in the current block.
      # Effectively this method will throw and exception unless the current block is
      # of type Document
      assert_missing_delimitation!
    end

    def end_tag
    end

    def unknown_tag(tag, params, tokens)
      case tag
      when 'else'
        raise SyntaxError, "#{block_name} tag does not expect else tag"
      when 'end'
        raise SyntaxError, "'end' is not a valid delimiter for #{block_name} tags. use #{block_delimiter}"
      else
        raise SyntaxError, "Unknown tag '#{tag}'"
      end
    end

    def block_delimiter
      "end#{block_name}"
    end

    def block_name
      @tag_name
    end

    def create_variable(token)
      token.scan(ContentOfVariable) do |content|
        return ::Liquid::Variable.new(content.first)
      end
      raise SyntaxError.new("Variable '#{token}' was not properly terminated with regexp: #{VariableEnd.inspect} ")
    end

    def render(context)
      render_all(@nodelist, context)
    end

    protected

    def assert_missing_delimitation!
      raise SyntaxError.new("#{block_name} tag was never closed")
    end

    def render_all(list, context)
      list.collect do |token|
        begin
          token.respond_to?(:render) ? token.render(context) : token
        rescue Exception => e
          context.handle_error(e)
        end
      end
    end
  end

  class Feed < Base
    class << self
      def partial; nil end


      def display_options
        [
          :display, :hide, :header_text, :header_class, 
          :feed_path, :feed_class, :feed_format, :show_rss_link, 
          :rss_link_text, :title_length, :title_class,
          :summary_length, :summary_class, :author_class, 
          :date_class, :image_class, :image_size, 
          :image_width, :image_height, :link, :summary_link, :width
        ]
      end
    end

    def render!
      if feed = context[self.class.tag_name]
        collection      = get_collection(feed)
        display_options = @attributes.slice(*self.class.display_options).merge(
          :collection => collection, 
          :liquid_tag => self.class.tag_name, 
          :feed_options => feed.feed_options
        )
        render_partial(self.class.partial, display_options)
      end
    end

    def get_collection(feed)
      feed.get(@attributes.slice(*feed.class.valid_options))
    end
  end
end

Dir["#{File.dirname(__FILE__)}/tags/*.rb"].each {|file| require file }
