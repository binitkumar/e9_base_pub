module Admin::UsersHelper
  def user_scope_select
    select_tag(:of_scope, options_for_select(user_scope_select_array, user_search_scope))
  end

  def user_scope_select_array
    user_search_scopes_for_current_user.map do |scope|
      ["#{User.human_attribute_name(scope)} (#{User.send(scope, current_user).count})", scope]
    end
  end

  def user_search_scopes_for_current_user
    User.search_scopes_for_user(current_user)
  end

  def user_search_scope
    controller.send(:search_scope) rescue ''
  end

  def user_default_scope
    controller.send(:default_scope)
  end

  def user_avatar_field(user)
    ''.html_safe.tap do |html|
      html << label_tag(:user, User.human_attribute_name(:avatar))
      html << image_tag(user.avatar_url, :id => :user_avatar)

      if user.avatar?
        link = link_to(e9_t(:reset_link), reset_avatar_admin_user_path, {
          :method => :delete, 
          :remote => true, 
          :id => :remove_user_avatar, 
          :class => "button reset"
        })

        html << content_tag(:div, link, :class => :actions)
      end
    end
  end

end
