module E9::Liquid::Drops
  class ContentFeed < E9::Liquid::Drops::Feed
    self.valid_options = [
      :context, 
      :content_name, :content_id,
      :labels, :tags, :match_any_label,
      :content_type, 
      :blog_name, :blog, :blog_id,
      :forum_name, :forum, :forum_id,
      :slideshow_name, :slideshow, :slideshow_id,
      :faq_name, :faq, :faq_id,
      :sort, :order, :reverse, 
      :role,
      :limit
    ]

    def get(opts = {})
      opts.symbolize_keys!

      feed_options = {}

      @scope = ::ContentView.feedable

      # TODO there is no scope for "name" in the feeds controller
      if (permalink = opts[:content_name] || opts[:name]).present?
        @scope = @scope.where(:permalink => permalink)
      elsif (id = opts[:content_id]).present?
        @scope = @scope.where(:id => id)
      end

      # tagging context
      if (context = opts[:context]).present?
        @scope = @scope.tagged_with_context(context)
        feed_options[:context] = context
      end

      # tags
      if (labels = opts[:labels] || opts[:tags]).present?
        opts[:match_any_label] = true if opts[:match_any_label].nil?

        unless labels.empty?
          @scope = @scope.tagged_with(labels, :any => opts[:match_any_label], :show_all => true)
          feed_options[:tagged_with] = labels
        end
      end

      # types
      @scope = process_content_type(@scope, opts[:content_type])

      # event feed
      if opts[:event_feed].present?
        @scope = @scope.of_type('Event')
        feed_options[:content_type] = ['Event']

        if opts[:event_type].present?
          @scope = @scope.of_parent(opts[:event_type])
          feed_options[:of_parent] = opts[:event_type]
        end

        # the future! NOTE this isn't passed to the feed options, do I care?
        @scope = @scope.from_time(Time.now, :column => :event_time)
      end

      # blog
      if (blog_permalink = opts[:blog_name] || opts[:blog]).present?
        ids = ::Blog.find_all_by_permalink(blog_permalink).map(&:id)
        @scope = @scope.of_blog(ids)
        feed_options[:of_blog] = ids
      elsif (ids = opts[:blog_id]).present?
        @scope = @scope.of_blog(ids)
        feed_options[:of_blog] = ids
      end

      # forum
      if (forum_permalink = opts[:forum_name] || opts[:forum]).present?
        ids = ::Forum.find_all_by_permalink(forum_permalink).map(&:id)
        @scope = @scope.of_forum(ids)
        feed_options[:of_forum] = ids
      elsif (ids = opts[:forum_id]).present?
        @scope = @scope.of_forum(ids)
        feed_options[:of_forum] = ids
      end

      # faq
      if (faq_permalink = opts[:faq_name] || opts[:faq]).present?
        ids = ::Faq.where(:permalink => faq_permalink).project(:id).map {|row| row.tuple[0] }
        @scope = @scope.of_faq(ids)
        feed_options[:of_faq] = ids
      elsif (ids = opts[:faq_id]).present?
        @scope = @scope.of_faq(ids)
        feed_options[:of_faq] = ids
      end

      # slideshow
      if (slideshow_permalink = opts[:slideshow_name] || opts[:slideshow]).present?
        ids = ::Slideshow.where(:permalink => slideshow_permalink).project(:id).map {|row| row.tuple[0] }
        @scope = @scope.of_slideshow(ids)
        feed_options[:of_slideshow] = ids
      elsif (ids = opts[:slideshow_id]).present?
        @scope = @scope.of_slideshow(ids)
        feed_options[:of_slideshow] = ids
      end

      # order 
      order_options = %w(alpha alphabetical published published_at updated updated_at top)

      if (order = opts[:sort] || opts[:order]) && order_options.member?(order.downcase)
        attribute = case order.downcase
          when 'alpha',     'alphabetical'  then :title
          when 'published', 'published_at'  then :published_at
          when 'updated',   'updated_at'    then :updated_at
          when 'top'                        then :top
          else order.downcase
        end

        if attribute == :top
          direction = ::E9.true_value?(opts[:reverse]) ? :asc : :desc
          @scope = @scope.top(direction)
          feed_options[:top] = direction
        else
          direction = ::E9.true_value?(opts[:reverse]) ? :desc : :asc
          @scope = @scope.order_by_attribute(attribute, direction)
          feed_options[:ordered_on] = attribute
          feed_options[:dir] = direction
        end
      else
        if feed_options[:of_slideshow].present?
          @scope = @scope.in_slideshow_order
        elsif opts[:event_feed].present?
          @scope = @scope.order_by_attribute('event_time', :asc)
        else 
          # NOTE default order is recent, which matches the controller
          @scope = @scope.recent
        end
      end

      # role
      @scope = process_role(@scope, opts[:role])

      # limit
      limit = opts[:limit].to_s =~ /\d+/ ? opts[:limit] : ::E9::Config[:feed_records]
      @scope = @scope.limit(limit)

      @scope
    end
  end
end
