class Admin::UserPagesController < Admin::PagesController
  include E9::Controllers::View

  add_resource_breadcrumbs

  protected

  ##
  # E9::Controllers::View
  #
  def params_for_build
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:user_id] ||= current_user.id
    params[resource_instance_name]
  end
end
