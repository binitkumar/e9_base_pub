class Admin::SearchesController < Admin::ResourceController
  include E9::Controllers::Orderable

  actions :index

  respond_to :js, :html

  add_resource_breadcrumbs

  protected

  def collection
    @searches ||= end_of_association_chain.paginate(pagination_parameters)
  end
end
