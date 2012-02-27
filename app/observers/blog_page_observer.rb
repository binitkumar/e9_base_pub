class BlogPageObserver < ActiveRecord::Observer
  observe :content_view

  # this is a hack to expire the cache for blog index in menus
  def after_save(record)
    if record.is_a?(BlogPost)
      if blog_index = Page.find_by_identifier(Page::Identifiers::BLOG_INDEX)
        blog_index.updated_at = DateTime.now
        blog_index.save(:validate => false)
      end
    end
  end
end
