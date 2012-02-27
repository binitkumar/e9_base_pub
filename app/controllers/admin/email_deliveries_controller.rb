class Admin::EmailDeliveriesController < Admin::ResourceController
  include E9::Controllers::Orderable

  belongs_to :user_email, :system_email, :email, :optional => true, :polymorphic => true

  filter_access_to :form, :require => :read, :context => :admin

  respond_to :js, :html

  add_resource_breadcrumbs
  actions :create, :new, :index

  def create
    create! do |success, error|
      success.html { redirect_to admin_email_deliveries_url }
      success.js { head :created }
    end
  end

  def form
    new! do |format|
      format.html { render 'new' }
    end
  end

  protected

  def method_for_association_build
    resource_params[:email_id] ? :build : :prepare
  end

  def add_index_breadcrumb
    add_breadcrumb e9_t(:index_title), :admin_email_deliveries_url
  end

  def default_ordered_on
    'created_at'
  end

  def default_ordered_dir
    'DESC'
  end

  def build_resource
    get_resource_ivar || begin 
      object = end_of_association_chain.send(method_for_build, resource_params)
      object.from = object.from.presence || current_user.email

      # validate resource first so we see errors when the form opens
      object.valid?

      set_resource_ivar object
    end
  end

  def collection
    get_collection_ivar || begin
      result = end_of_association_chain.with_visits.paginate(pagination_parameters)

      set_collection_ivar result
    end
  end

  def resource_params
    (params[resource_instance_name] || {}).dup
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
