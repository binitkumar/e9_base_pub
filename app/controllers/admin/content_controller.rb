class Admin::ContentController < Admin::ResourceController
  before_filter :add_admin_content_breadcrumb

  protected

  def add_admin_content_breadcrumb
    #add_breadcrumb e9_t(:admin_content_breadcrumb), :admin_content_path
  end
end
