class Admin::BannersController < Admin::ContentController
  include E9::Controllers::Orderable

  respond_to :html, :js

  skip_after_filter :flash_to_headers, :on => :create
  add_resource_breadcrumbs
  before_filter :add_manage_breadcrumb, :only => :manage

  def manage
    @toolbar_help_key = :manage_toolbar_help
    render
  end

  def create; create! { collection_path } end
  def update; update! { collection_path } end

  def destroy 
    destroy! do |format|
      format.html { redirect_to collection_path } 
    end
  end

  protected

  ##
  # IR
  # 
  def collection 
    @banners ||= end_of_association_chain.for_roleable(current_user).paginate(pagination_parameters)
  end

  ##
  # breadcrumb
  #
  def add_manage_breadcrumb
    add_breadcrumb! @manage_title = e9_t(:manage_title, :name => resource.name)
  end

  ##
  # Orderable
  #
  def default_ordered_on;  'name' end
  def default_ordered_dir; 'ASC'  end
end
