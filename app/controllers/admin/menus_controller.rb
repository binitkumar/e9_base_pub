class Admin::MenusController < Admin::ContentController

  MAIN_MENU_SLUG = 'main'

  actions :index

  respond_to :html, :js

  add_resource_breadcrumbs

  protected

  ##
  # IR
  #
  def collection
    @menus ||= Menu.roots
  end

  protected

  def resource
    @menu ||= params[:id] == MAIN_MENU_SLUG ? Menu.master : Menu.find(params[:id])
  end

end
