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

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find(params[:id]))
  end
end
