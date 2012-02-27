# NOTE this is mostly or all obsolete, referring to the old static widget templates
module FeedsHelper
  
  def feed_thumb_image(object, image_size)
    image_size.present? && object.respond_to?(image_size) ? object.send(image_size) : object.thumb
  end

  def init_feed_options(assigns)
    ltag         = assigns[:liquid_tag]   || 'liquid_tag'
    feed_options = assigns[:feed_options] || {}

    {}.tap do |opts|
      opts[:feed_format]   = %w(ul ol div).member?(assigns[:feed_format]) ? assigns[:feed_format].to_sym : :ul
      opts[:list_format]   = opts[:feed_format] == :div ? :div : :li
      opts[:header_text]   = assigns[:header_text]
      opts[:show_rss_link] = E9.true_value?(assigns[:show_rss_link])
      opts[:rss_link_text] = assigns[:rss_link_text]
      opts[:header_class]  = ['header', assigns[:header_class]].compact.join(' ')
      opts[:feed_class]    = ltag.dasherize
      opts[:feed_class]   << " #{assigns[:feed_class]}" if assigns[:feed_class]
      opts[:feed_path]     = assigns[:feed_path] || case ltag
                                                    when 'content_feed'
                                                      content_views_url(feed_options.merge(:format => :rss))
                                                    end
    end
  end

  def init_listing_options(assigns)
    {}.tap do |opts|
      opts[:link]                     = %w(page image).member?(assigns[:link]) ? assigns[:link].to_sym : :page
      opts[:title_class]              = ['title', assigns[:title_class]].compact.join(' ')
      opts[:summary_class]            = ['summary', assigns[:summary_class]].compact.join(' ')
      opts[:author_class]             = ['author', assigns[:author_class]].compact.join(' ')
      opts[:published_date_class]     = ['published-date', assigns[:published_date_class]].compact.join(' ')
      opts[:updated_date_class]       = ['updated-date', assigns[:updated_date_class]].compact.join(' ')
      opts[:image_class]              = ['image', assigns[:image_class]].compact.join(' ')
      opts[:title_length]             = (assigns[:title_length]   || E9::Config[:feed_max_title_characters]).to_i
      opts[:summary_length]           = (assigns[:summary_length] || E9::Config[:feed_summary_characters]).to_i
      opts[:summary_link]             = E9.true_value?(assigns[:summary_link])
      opts[:image_height]             = assigns[:image_height]
      opts[:image_width]              = assigns[:image_width]
      opts[:image_size]               = assigns[:image_size]

      hide = assigns[:hide].try(:map, &:downcase) || []

      elements = %w( image title summary author updated_date published_date )

      # if display is not passed, default to all elements
      display = assigns[:display].try(:map, &:downcase) || elements

      # hide takes precedence
      elements.each do |val|
        opts[:"display_#{val}"] = display.member?(val) && !hide.member?(val)
      end
    end
  end

end
