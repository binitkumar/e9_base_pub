class Admin::EmailsController < Admin::ResourceController
  include E9::Controllers::Orderable
  include E9::Controllers::InheritableViews

  respond_to :js, :html

  filter_access_to :send_email, :context => :admin, :require => :update

  before_filter :add_admin_email_breadcrumb

  use_tiny_mce :only              => [:edit, :update, :new, :create],
               :skip_default      => true,
               :use_absolute_urls => true,
               :unstyled          => true

  add_resource_breadcrumbs

  def send_email
    object = resource

    object.send!(*prepare_email_args)

    respond_with(object) do |format|
      format.html { redirect_to admin_email_deliveries_url }
      format.js { head :ok }
    end
  end

  def create 
    create! { collection_path }
  end

  def update
    update! { collection_path }
  end

  protected

  def prepare_email_args
    args    = []
    options = {}

    if params[:test]
      args << current_user
      options[:test] = true
    end

    if params[:user_ids] =~ /^\[?((\d+,?\s?)+)\]?$/
      options[:recipients] = $1.split(',')
    end

    (args << options)
  end

  def add_admin_email_breadcrumb
    add_breadcrumb e9_t(:admin_email_breadcrumb), :admin_email_path
  end

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end

  def build_resource
    get_resource_ivar || begin
      copy_id = params.delete(:copy_id)

      if params[resource_instance_name].blank? && 
          copy = resource_class.find_by_id(copy_id)

        params[resource_instance_name] = copy.copy_attributes
      end

      set_resource_ivar resource_class.new(params[resource_instance_name] || {})
    end
  end

  def collection_scope
    end_of_association_chain
  end

  def collection
    get_collection_ivar || begin
      set_collection_ivar collection_scope.paginate(pagination_parameters)
    end
  end
end
