class FavoritablesObserver < ActiveRecord::Observer
  observe :content_view

  def publish_content(favoritable)
    send_to_auto_favoriters(favoritable) if favoritable.class.favoritable?
  end

  protected

  def send_to_auto_favoriters(favoritable)
    User.auto_favoriters.each {|user| user.favorites.create(:favoritable => favoritable) }
  end
end
