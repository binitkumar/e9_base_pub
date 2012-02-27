class Admin::SlidesController < Admin::PagesController
  include E9::Controllers::Sortable
  include E9::Controllers::View

  belongs_to :slideshow, :finder => :find_by_permalink!, :optional => true
  before_filter :association_chain

  carrierwave_column_methods :image, :context => :admin
  add_resource_breadcrumbs

  filter_access_to :index, :attribute_check => true, :load_method => :filter_target, :context => :admin

  skip_after_filter :flash_to_headers, :only => :create

  has_scope :of_layout, :only => :index, :default => '' do |controller, scope, value|
    return scope if controller.send(:parent?)

    if value.present?
      scope.of_layout(value)
    else
      scope.send(:default_layout_scope)
    end
  end

  def destroy
    destroy! do |format|
      format.html { page_update_redirect }
      format.js do 
        path = polymorphic_path([:admin, resource_class])
        path = session[:return_to] if Regexp.new(path) =~ session[:return_to]
        head :status => 204, :location => path
      end
    end
  end

  def add
    object = resource_by_id_without_chain

    if parent?
      parent.slides << object unless parent.slides.member?(object)
    end

    respond_with(collection) do |format|
      format.js { render 'index' }
    end
  end

  def remove
    object = resource

    if parent?
      parent.slides.delete(object)
    end
  end

  protected
  
  def row_partial
    parent ? 'in_slideshow_row' : 'row'
  end

  def filter_target
    if parent?
      parent
    else
      params[:id].present? ? resource : Slide.new
    end
  end

  # slides are created via the mini form and shouldn't load the shared
  def page_create_render
    'create'
  end

  # admin_slideshow_slides or simply admin_slides path depending on parent
  def page_update_redirect
    polymorphic_path([:admin, parent, resource_class])
  end

  def page_create_redirect
    page_update_redirect
  end

  def index_path_with_layout
    args = [[:admin, parent, resource_class]]
    args << { :of_layout => resource.layout_id } if params[:id] && !parent

    polymorphic_path(*args)
  end

  ##
  # E9::Controllers::View
  #
  def params_for_build 
    params[resource_instance_name] ||= {}
    params[resource_instance_name][:user_id] ||= current_user.id
    params[resource_instance_name][:slideshow_ids] = [parent.try(:id)]
    params[resource_instance_name]
  end

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_permalink!(params[:id]))
  end

  def resource_by_id_without_chain
    get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
  end

  def collection
    if parent?
      get_collection_ivar || set_collection_ivar(end_of_association_chain.all) 
    else
      super
    end
  end

  def add_index_breadcrumb
    if parent?
      add_breadcrumb 'Slideshows', admin_slideshows_path
      add_breadcrumb @index_title = e9_t(:manage_slideshow_title, :slideshow => parent.title), admin_slideshow_slides_path(parent)
    else
      add_breadcrumb @index_title = e9_t(:index_title, :layout => layout_name), admin_slides_path(:of_layout => slide_layout ? slide_layout.id : nil)
    end
  end

  def layout_name
    @_layout_name ||= slide_layout.present? ? slide_layout.name : e9_t(:all_layouts)
  end

  def slide_layout
    @_slide_layout ||= begin
      n = Layout.find_by_id(params[:of_layout]) if params[:of_layout]
      n = resource.layout if params[:id]
      n
    end
  end

  def slide_layout_id
    slide_layout.try(:id)
  end

  helper_method :slide_layout_id

  def layout_scope
    params[:of_layout] || default_layout_scope
  end

  def default_layout_scope
    @_default_layout_scope ||= Layout.for_page_class(Slide)
  end

  private

  def _do_position_update(id, hash_with_position)
    SlideshowAssignment.update_all ["position = ?", hash_with_position[:position]], ["slide_id = ? && slideshow_id = ?", id, parent.id]
  end

end
