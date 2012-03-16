class SlideDecorator < BaseDecorator
  decorates :slide

  delegate :slideshow, :slideshow=, :to => :model

  def as_json(options = {})
    {}.tap do |hash|
      hash[:id]             = model.id
      hash[:type]           = model.class.name
      hash[:param]          = model.to_param
      hash[:image]          = model.image.as_json
      hash[:title]          = model.title
      hash[:description]    = model.description
      hash[:url]            = h.contextual_slide_url(model)
      hash[:author]         = model.author_name
      hash[:layout]         = jst_layout(model)
      hash[:related_images] = model.images
      hash[:page]           = h.collection.page(model)
      hash[:page_title]     = h.slide_page_title(model, h.parent)
      hash[:updated_at]     = updated_at.utc
      hash[:created_at]     = created_at.utc

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
        hash[:html] = {}.tap do |html|
          html[:regions]    = regions_html_hash
          html[:pagination] = pagination
          html[:dashboard]  = dashboard
          html[:body]       = body
          html[:tags]       = tags
          html[:image]      = image_tag
          html[:title]      = model.display_title? && model.title || ''

          if model.allow_comments?
            html[:comments]   = comments_html
          end
        end
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

  def comments_html
    html_render { h.content_comments(model) }
  end

  def labels
    html_render { h.content_labels(model) }
  end
  alias :tags :labels

  def body
    h.render_liquid(model.body)
  end

  def byline
    h.content_byline(model)
  end

  def dateline
    h.content_dateline(model)
  end

  # We do this for caching, so requests returning HTML in JSON do not cache.
  # We can't cache HTML for Ajax because it's user specific (admin only HTML, etc)
  def updated_at
    h.params[:html] ? Time.now : model.updated_at
  end

  def created_at
    model.created_at
  end

  protected

  def render_slide_partial(partial)
    html_render { h.render("slides/#{partial}", :resource => model) }
  end

  def jst_layout(model)
    model.layout && File.basename(model.layout.template.to_s, '.*')
  end
end
