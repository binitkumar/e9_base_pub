class Admin::SoftLinksController < Admin::ContentController

  actions :new, :edit, :create, :update, :destroy
  add_resource_breadcrumbs

  respond_to :html, :except => :destroy
  respond_to :js, :only => :destroy

  before_filter :prepare_build_params, :only => :new

  def create
    create! do |success, failure|
      success.html { redirect_to(admin_menu_submenus_path(resource.root)) }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to(admin_menu_submenus_path(resource.root)) }
    end
  end

  protected

  def add_index_breadcrumb
    add_breadcrumb e9_t(:index_title, :scope => :"admin.menus", :resource_class => Menu), admin_menu_path(1)
  end

  def add_new_breadcrumb
    add_breadcrumb!(@new_title = e9_t(:new_title, :parent => find_parent.try(:name) || "Menu"))
  end

  def find_parent
    @parent ||= Menu.find_by_id(params[:parent_id])
  end

  def prepare_build_params
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:parent_id] ||= params[:parent_id]
    params[resource_instance_name]
  end
end
