class Admin::CategoriesController < Admin::ContentController
  include E9::Controllers::Sortable

  respond_to :html, :js
  
  add_resource_breadcrumbs

  def create; create! { collection_path } end
  def update; update! { collection_path } end
  def destroy
    destroy! do |format|
      format.html { redirect_to collection_path } 
      format.js
    end
  end

  protected

  ##
  # IR
  # 
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.for_roleable(current_user).order(:position).all)
  end

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_permalink!(params[:id]))
  end
end
