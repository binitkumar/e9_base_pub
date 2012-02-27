class Admin::SystemPagesController < Admin::PagesController
  include E9::Controllers::View

  add_resource_breadcrumbs

  protected

  # System pages are found by identifier, not permalink (they don't typically have one)
  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_identifier!(params[:id]))
  end

  def collection
    @system_pages ||= end_of_association_chain.for_roleable(current_user).paginate(pagination_parameters)
  end

  ##
  # Orderable
  #
  
  def default_ordered_dir
    'asc'
  end

  def default_ordered_on
    'title'
  end
end
