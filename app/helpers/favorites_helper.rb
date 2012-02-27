module FavoritesHelper
  def render_favorites(favorites)
    favorites.map do |favorite|
      favoritable = favorite.favoritable
      add_actions_list_item(remove_favorite_link(favorite))
      render "#{favoritable.class.model_name.collection}/listing", :listing => favoritable
    end.join.html_safe
  end

  def show_more_favorites_link(favorites, opts = {})
    opts[:offset] = offset = (opts[:offset] || 0 ).to_i + favorites.length

    count = [favorites.total_entries - offset, pagination_per_page].min

    return if count <= 0

    link_to(e9_t(:show_more_link, :count => count),
            profile_favorites_path(opts.slice(:offset, :for_user)),
            :"data-offset" => offset,
            :remote => true, 
            :class => "show-more-link")
  end

  def remove_favorite_link(favorite)
    link_to e9_t(:remove_favorite_link, :scope => 'favorites'), 
            profile_favorite_path(favorite), 
            :remote => true,
            :method => :delete
  end

  def favorites_div_id(favorite_type = nil)
     case favorite_type
     when Class
       "favorite-#{favorite_type.model_name.collection.dasherize.pluralize}"
     when Symbol, String
       "favorite-#{favorite_type.to_s.dasherize.pluralize}"
     else
       "favorites"
     end
  end

  def favorite_toggle(favoritable)
    favorite = current_user ? Favorite.for_user_and_favoritable(current_user, favoritable) : nil

    if favorite
      title = e9_t(:remove_favorite_link_title, :scope => :favorites)
      link_to('Unsave', profile_favorite_path(favorite), 
                        :method => :delete, 
                        :remote => true, 
                        :alt    => "unsave favorite icon",
                        :title  => title,
                        :class  => "icon-unfavorite")
    else
      title = e9_t(:add_favorite_link_title, :scope => :favorites)
      link_to('Save', profile_favorites_path(:favorite => {:favoritable_id => favoritable.id, :favoritable_type => favoritable.class.base_class.model_name}), 
                        :method => :post, 
                        :alt    => "save favorite icon",
                        :title  => title,
                        :remote => true, 
                        :class => "icon-favorite")
    end
  end

end
