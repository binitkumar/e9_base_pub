module ForumsHelper
  def forums_title(forum)
    forum_index_page.try(:title) || 'Forums'
  end

  def forum_index_page
    @_forum_index_page ||= ContentView.find_by_identifier(Page::Identifiers::FORUM_INDEX)
  end
end
