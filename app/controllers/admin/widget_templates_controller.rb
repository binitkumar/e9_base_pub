class Admin::WidgetTemplatesController < Admin::ContentController
  include E9::Controllers::Orderable
  
  add_resource_breadcrumbs

  has_role_scope

  def create; create! { collection_path } end
  def update; update! { collection_path } end
  def destroy
    destroy! do |format|
      format.html { redirect_to collection_path } 
      format.js
    end
  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(pagination_parameters))
  end
end
