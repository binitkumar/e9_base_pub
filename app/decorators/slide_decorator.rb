class SlideDecorator < ContentViewDecorator
  decorates :slide

  delegate :slideshow, :slideshow=, :to => :model

  def as_json(options = {})
    super.tap do |hash|
      hash[:image]      = model.image.as_json
      hash[:page]       = h.collection.page(model)
      hash[:page_title] = h.slide_page_title(model, h.parent)

      if h.parent?
        hash[:slideshow_link]  = h.contextual_slide_url(model, h.parent)
        hash[:slideshow_title] = h.parent.title

        # keep the :search param intact for custom slideshows
        # TODO should we keep other params?  order, limit, etc?
        args = h.params.slice(:search)

        if next_slide = h.collection.after(model, true)
          args.merge!(:id => next_slide.to_param)

          hash[:next_slide] = 
            h.parent.persisted? ? h.parent.url(args) : slides_url(args)
        end

        if previous_slide = h.collection.before(model, true)
          args.merge!(:id => previous_slide.to_param)

          hash[:previous_slide] = 
            h.parent.persisted? ? h.parent.url(args) : slides_url(args)
        end
      end

      if h.params[:html]
        html = hash[:html] ||= {}
        html[:pagination] = pagination
        html[:dashboard]  = dashboard
        html[:image]      = image_tag
      end
    end
  end

  def image_tag
    h.image_mount_tag(model.image)
  end

  def pagination
    render_slide_partial('pagination')
  end

  def dashboard
    render_slide_partial('dashboard')
  end

  protected

    def _url
      # h.contextual_slide_url(model)
      model.url
    end

    def render_slide_partial(partial)
      html_render { h.render("slides/#{partial}", :resource => model) }
    end

end
