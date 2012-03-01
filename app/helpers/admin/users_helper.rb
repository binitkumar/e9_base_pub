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
end
