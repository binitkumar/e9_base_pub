class ContentViewDecorator < BaseDecorator
  def as_json(options = {})
    {}.tap do |hash|
      hash[:id]             = model.id
      hash[:type]           = model.class.name
      hash[:param]          = model.to_param
      hash[:title]          = model.title
      hash[:description]    = model.description
      hash[:author]         = model.author_name
      hash[:layout]         = jst_layout(model)
      hash[:related_images] = model.images
      hash[:updated_at]     = updated_at.utc
      hash[:created_at]     = created_at.utc
      hash[:url]            = _url

      if h.params[:html]
        hash[:html] = {}.tap do |html|
          html[:regions] = regions_html_hash
          html[:body]    = body
          html[:tags]    = tags
          html[:title]   = model.display_title? && model.title || ''

          if model.allow_comments?
            html[:comments] = comments_html
          end
        end
      end
    end
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

    def _url
      model.url
    end

    def jst_layout(model)
      model.layout && File.basename(model.layout.template.to_s, '.*')
    end

end
