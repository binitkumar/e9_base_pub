class Admin::RenderablesController < Admin::ContentController
  respond_to :html, :js
  include E9::Controllers::Orderable
  filter_access_to :replace, :require => :update, :context => :admin

  before_filter :handle_unacceptable_mimetype
  before_filter :ensure_region_type_ids_in_params, :only => [:create, :update]

  def create; create! { collection_url } end
  def update; update! { collection_url } end

  def replace
    set_resource_ivar(resource.clone)
    resource.node_ids = [params[:node_id]]

    respond_to do |format|
      format.html { render 'edit' }
    end
  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar( end_of_association_chain.paginate(pagination_parameters) )
  end

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end

  def determine_layout
    return false if request.xhr?
    super
  end

  def ensure_region_type_ids_in_params
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:region_type_ids] ||= []
  end
end
