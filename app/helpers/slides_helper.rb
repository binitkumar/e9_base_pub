module SlidesHelper
  def slideshow_javascript_includes
    unless @_slideshow_javascript_included
      @_slideshow_javascript_included = true
      include_javascripts :slideshows
    end
  end

  def slide_page_title(slide_or_title, slideshow = nil)
    slide_or_title = slide_or_title.meta_title if slide_or_title.respond_to?(:meta_title)
    meta_title([slide_or_title, slideshow.presence && slideshow.title])
  end

  def slide_pagination_info(slide, slides_relation)
    if slide.nil?
      ''
    else
      e9_t :slide_pagination, :position => slides_relation.position(slide), :count => slides_relation.count
    end
  end

  #
  # expects slide_link(slide, slideshow, options) or slide_link(slide, options) 
  # depending on the context
  #
  # accepts options:
  #   :version       => :embeddable or :thumb (default :thumb)
  #   :image_options => a hash passed to the image helper
  #
  # all other options passed are sent to the link helper
  #
  def slide_link(*args)
    opts = args.extract_options!
    slide, show = args

    return '' unless slide.present?

    link = opts.delete(:text) || begin
      mount         = slide.send(opts.delete(:version) || :thumb)
      image_options = opts.delete(:image_options) || {}
      image_options.reverse_merge!(
        :alt => slide.title, 
        :title => e9_t(:slide_link_title, :title => slide.title)
      )

      image_mount_tag(mount, image_options)
    end
   
    link_to link, contextual_slide_path(*args.compact), opts
  end

  def slide_previous_link(*args)
    opts = args.extract_options!
    _slide_pagination_link *args, opts.reverse_merge({
      :text => e9_t(:previous_page_link).html_safe, 
      :_method => :before
    })
  end

  def slide_next_link(*args)
    opts = args.extract_options!
    _slide_pagination_link *args, opts.reverse_merge({
      :text => e9_t(:next_page_link).html_safe, 
      :_method => :after
    })
  end

  #
  # determine the appropriate url for a slide based on the current context
  #
  # when no slideshow            => standalone permalink
  # when slideshow is new_record => within a custom/pseudo slideshow
  # when slideshow persisted     => within an actual slideshow
  #
  # accepts options:
  #   only_path : in the same way as url_for
  #
  def contextual_slide_url(*args)
    options = args.extract_options!
    options.slice!(:only_path, :page, :per_page)

    # change determinant to fix issue with SlideDecorator
    slideshow = args.find {|arg| arg.respond_to?(:slides) }
    slide     = args.find {|arg| arg.respond_to?(:slideshows) }

    if slideshow.blank?
      if slide.present?
        slide_url(slide, options)
      else
        ''
      end
    else
      if slide.present?
        options[:anchor] = slide.to_param
      end

      if slideshow.new_record?
        slides_url options.reverse_merge(slide_query_params)
      else
        slideshow_url slideshow, options
      end
    end
  end

  def contextual_slide_path(*args)
    options = args.extract_options!
    contextual_slide_url(*args, options.merge(:only_path => true))
  end

  private

  def _slide_pagination_link(*args)
    opts = args.extract_options!

    slide, show, relation = args

    if relation.present?
      paged = relation.send(opts.delete(:_method), slide)
    elsif show.present?
      paged = show.send(opts.delete(:_method), slide)
    end

    unless paged.present?
      content_tag(:span, opts[:text], :class => 'inactive')
    else
      slide_link(paged, show, opts)
    end
  end
end
