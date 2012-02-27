class Admin::SubmenusController < Admin::ContentController

  belongs_to :menu, :optional => false
  defaults :resource_class => Menu
  filter_access_to :update_order, :require => :update, :context => :admin

  prepend_before_filter :set_parent_if_main_menu

  skip_js_skippable_filters :only => :update_order

  helper_method :parent, :parent?

  add_resource_breadcrumbs

  respond_to :html, :except => :update_order
  respond_to :js

  def update_order
    success = if child_ids = params[:ids]
      # not sure if this is the best way, but nullifying the childrens' parent_id first ...
      parent.child_ids = []

      # ... then resetting them in the order passed will reorder the children.
      parent.child_ids = child_ids

      # TODO investigate awesome_nested_set to find if there's a less expensive way to reorder children
      # NOTE no need to save here because of how child_ids= works
    end

    respond_with(collection) do |format|
      format.html { render :index }
    end
  end

  protected

  def set_parent_if_main_menu
    if params[:menu_id] == Admin::MenusController::MAIN_MENU_SLUG
      @menu = Menu.master
      params[:menu_id] = @menu.id
    end
  end

  def add_index_breadcrumb
    parent.ancestors.each do |ancestor|
      add_breadcrumb e9_t(:index_title, :parent => ancestor.link_text), admin_menu_submenus_path(ancestor)
    end

    add_breadcrumb @index_title = e9_t(:index_title, :parent => parent.link_text), admin_menu_submenus_path(parent)
  end

  def method_for_association_chain
    :children
  end
end
