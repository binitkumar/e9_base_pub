class Admin::SettingsController < Admin::ResourceController

  before_filter :add_admin_settings_breadcrumb
  before_filter :add_index_breadcrumb

  def update
    update! do |format|
      format.html { render 'show' }
    end
  end

  protected

  def add_admin_settings_breadcrumb
    add_breadcrumb e9_t(:admin_settings_breadcrumb), :admin_settings_path
  end

  def resource
    get_resource_ivar || set_resource_ivar(E9::Config.instance(true))
  end
end
