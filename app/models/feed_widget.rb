class FeedWidget < Renderable
  include Renderable::Widget

  validates :template_id, :presence => true

  self.tag_name = 'content_feed'

  self.options_parameters |= [
    :author_class, 
    :blog_id, 
    :content_id, 
    :content_type, 
    :event_feed,
    :event_type,
    :feed_class, 
    :feed_format, 
    :forum_id, 
    :header_class, 
    :hide,
    :image_class, 
    :image_height,
    :image_size, 
    :image_width, 
    :link, 
    :published_date_class, 
    :show_rss_link, 
    :slideshow_id, 
    :summary_class,
    :summary_length, 
    :summary_link, 
    :title_class, 
    :title_length, 
    :updated_date_class
  ]
end
