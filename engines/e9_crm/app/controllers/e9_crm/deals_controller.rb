class E9Crm::DealsController < E9Crm::ResourcesController
  defaults :resource_class => Deal
  include E9::Controllers::Orderable

  # for campaign select options
  helper :"e9_crm/campaigns"

  filter_access_to :leads, :require => :read, :context => :admin
  filter_access_to :edit_costs, :update_costs, :require => :update, :context => :admin

  #skip_after_filter :flash_to_headers, :except => [:destroy, :create]

  prepend_before_filter :set_leads_index_title, :only => :leads

  before_filter :prepop_deal_owner_contact, :only => [:new, :edit]

  before_filter :redirect_for_default_from_time, :only => :leads

  ##
  # All Scopes
  #

  has_scope :until_time, :as => :until, :unless => 'params[:from].present?'
  has_scope :from_time, :as => :from do |controller, scope, value|
    if controller.params[:until]
      scope.for_time_range(value, controller.params[:until])
    else
      scope.from_time(value)
    end
  end

  has_scope :closed_in_month, :as => :closed, :only => :index do |controller, scope, value|
    scope.for_time_range(value, :column => :closed_at, :in => :month)
  end

  ##
  # Leads Scopes
  #
  
  # NOTE default => 'true' only exists to ensure this scope is called
  has_scope :only_leads, :only => :leads, :default => 'true' do |controller, scope|
    scope.leads(true)
  end

  has_scope :offer, :only => :leads

  ##
  # Index Scopes
  #
  
  # NOTE default => 'false' only exists to ensure this scope is called
  has_scope :no_leads, :only => :index, :default => 'false' do |controller, scope|
    scope.leads(false)
  end

  has_scope :category, :only => :index
  has_scope :owner, :only => :index
  has_scope :status, :only => :index, :default => 'pending' do |controller, scope, value|
    # NOTE make only valid deal statuses trigger this.  This way in the form "pending" can
    # be a blank value to trigger the default and still appear as the selected option, while
    # "all" (or anything) can be passed for all statuses.
    if %w(pending won lost).member?(value)
      scope = scope.status(value)
    end
    scope
  end

  ##
  # Actions
  #

  def leads
    @toolbar_help_key = :leads_toolbar_help
    index!
  end

  def create
    create! { determine_collection_path }
  end

  def update
    update! { determine_collection_path }
  end

  def update_costs
    update! do |success, failure|
      success.html { redirect_to resource }
      failure.html { render 'edit_costs' }

      success.js { render 'update' }
      failure.js { render 'update' }
    end
  end

  protected

  def add_new_breadcrumb(opts = {})
    determine_if_conversion
    add_breadcrumb!(@new_title = e9_t(:new_title, interpolation_options))
  end

  def add_edit_breadcrumb(opts = {})
    add_show_breadcrumb
    add_breadcrumb!(@edit_title = e9_t(:edit_title, interpolation_options))
  end

  def add_show_breadcrumb
    determine_if_conversion

    unless resource.status == Deal::Status::Lead
      add_breadcrumb! resource.name, resource.url
    end
  end

  # nasty hack to get Lead in as a model_name on actions where this is
  # treated as a lead.  Used here for breadcrumbs and for flash i18n
  def interpolation_options
    if determine_resource.lead?
      { 
        :model         => 'Lead',
        :models        => 'Leads',
        :collection    => 'leads',
        :element       => 'lead',
        :resource_name => 'Lead',
        :downcase_resource_name => 'lead'
      }
    else
      {}
    end
  end

  # TODO the leads table references offer each row, and it is not joined here
  def collection
    get_collection_ivar || begin
      scope = end_of_association_chain.
        joins("LEFT OUTER JOIN contacts ON contacts.id = deals.contact_id").
        joins("LEFT OUTER JOIN campaigns ON campaigns.id = deals.campaign_id").
        select("deals.*, contacts.first_name owner_name, campaigns.name campaign_name")

      if params[:action] == 'leads'
        objects = scope.paginate(pagination_parameters)
      else
        objects = scope.all
      end

      set_collection_ivar objects
    end
  end

  def prepop_deal_owner_contact
    object = determine_resource

    if !object.owner && contact = current_user.contact
      object.owner = contact
    end
  end

  def set_leads_index_title
    @index_title = I18n.t(:index_title, :scope => 'e9.e9_crm.leads')
  end

  def should_paginate_index
    params[:action] == 'leads'
  end

  def ordered_if 
    %w(index leads).member? params[:action]
  end

  def default_ordered_on 
    params[:action] == 'leads' ? 'created_at' : 'name' 
  end

  def default_ordered_dir 
    params[:action] == 'leads' ? 'DESC' : 'ASC' 
  end

  # for leads, redirect index with a default :from of the current month
  def redirect_for_default_from_time
    format = request.format.blank? || request.format == Mime::ALL ? Mime::HTML : request.format

    if format.html? && params[:from].blank?
      url = params.slice(:controller, :action)
      url.merge!(default_from_time_params)
      redirect_to url and return false
    end
  end

  def determine_if_conversion
    if params.delete(:convert)
      determine_resource.status = Deal::Status::Pending
    end
  end

  def determine_resource
    params[:id] ? resource : build_resource
  end

  def determine_collection_path
    object = determine_resource

    if object.lead?
      leads_path(default_from_time_params)
    else
      polymorphic_path(object)
    end
  end

  def default_from_time_params
    { :from => Date.today.strftime('%Y/%m') }
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
