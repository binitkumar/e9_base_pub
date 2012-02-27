class ForumPageObserver < ActiveRecord::Observer
  observe :forum

  # this is a hack to expire the cache for forum index in menus
  def after_save(record)
    if forum_index = Page.find_by_identifier(Page::Identifiers::FORUM_INDEX)
      forum_index.updated_at = DateTime.now
      forum_index.save(:validate => false)
    end
  end
end
