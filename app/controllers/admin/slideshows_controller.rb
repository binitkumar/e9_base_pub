class Admin::SlideshowsController < Admin::ContentController
  include E9::Controllers::Sortable

  include E9::Social::Controller

  respond_to :html, :js

  add_resource_breadcrumbs

  def create;  create! { collection_path } end
  def destroy; destroy! { collection_path } end
  def update; update! { collection_path } end

  protected

  def params_for_build
    (params[resource_instance_name] ||= {}).tap do |build_params|
      build_params[:author] ||= current_user
    end
  end

  def collection
    @slideshows ||= end_of_association_chain.paginate(pagination_parameters)
  end

  def resource
    @slideshow ||= Slideshow.find_by_permalink!(params[:id])
  end

  def build_resource
    @slideshow ||= Slideshow.new(params_for_build)
  end
end
