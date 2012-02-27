module Admin::CategoriesHelper
  def category_scope_select(current_scope)
    scopes = Category::SCOPES.map {|x| [x.to_s.titleize, x.to_s] }
    select_tag(:scope, options_for_select(scopes, current_scope ? current_scope.to_s : nil))
  end
end
