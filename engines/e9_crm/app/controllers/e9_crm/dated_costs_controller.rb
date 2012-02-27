class E9Crm::DatedCostsController < E9Crm::ResourcesController
  defaults :resource_class => DatedCost
  belongs_to :advertising_campaign, :contact, :polymorphic => true, :optional => true

  include E9::Controllers::Orderable

  self.should_paginate_index = false

  filter_access_to :bulk_create, :require => :create, :context => :admin
  filter_access_to :payments, :advertising_costs, :payments, :require => :read, :context => :admin

  before_filter :determine_title, :except => [:new, :edit, :create, :update]

  prepend_before_filter :association_chain

  def payments
    @toolbar_help_key = :payments_toolbar_help
    @contacts = DatedCost.
                  for_contacts.includes(:contact).all.
                  group_by(&:contact).
                  sort_by {|contact, payments| contact.name.upcase }
  end

  def advertising_costs
    @advertising_campaigns = AdvertisingCampaign.active.ordered
    render 'bulk_form'
  end

  def bulk_create
    params[:id].zip(params[:cost]) do |id, cost|
      DatedCost.create({
        :costable_id   => id,
        :costable_type => AdvertisingCampaign.base_class.name,
        :date          => params[:date],
        :cost          => cost
      })
    end

    flash[:notice] = "Advertising Costs Added"
    redirect_to :marketing_report
  end

  def create
    create! do |success, failure|
      success.html { redirect_to parent_collection_path }
      success.js { head 201, :location => parent_collection_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to parent_collection_path }
      success.js { head 204, :location => parent_collection_path }
    end
  end

  protected

    def parent_collection_path
      polymorphic_path([parent, resource_class])
    end

    def resource_params
      super.tap do |hash|
        # NOTE Only credits are created through the web interface,
        #      but both credits and existing payments can be created.
        if %w(new create).member? params[:action]
          hash[:credit] = parent.is_a?(Contact)
        end
      end
    end

    def destroy_resource(object)
      # NOTE this is just a precaution as it should not be possible to delete
      #      deal associated costs through the web interface via normal means
      if object.deal.present?
        errors = object.errors.add(:deal, :delete_restricted)
        flash[:alert] = errors.last
      else
        object.destroy
      end
    end

    def add_index_breadcrumb
      if params[:action] == 'payments' || parent.is_a?(Contact)
        add_breadcrumb i18n_translate(:breadcrumb, :payments), payments_contacts_path

      # NOTE this doesn't need a path really, it's always the last crumb
      elsif %w(bulk_create advertising_costs).member? params[:action]
        add_breadcrumb i18n_translate(:breadcrumb, :advertising_costs), advertising_costs_path
      end

      if parent
        add_breadcrumb! i18n_translate(:breadcrumb), parent_collection_path
      end
    end

    def add_new_breadcrumb(opts = {})
      object_name = build_resource.credit? ? 'Payment' : 'Cost'
      add_breadcrumb!(@new_title = "Add #{object_name}")
    end

    def add_edit_breadcrumb(opts = {})
      object_name = resource.credit? ? 'Payment' : 'Cost'
      add_breadcrumb!(@edit_title = "Edit #{object_name}")
    end

    def determine_title
      instance_variable_set "@#{i18n_key}_title", i18n_translate(:title)
    end

    def i18n_key
      @_key ||= case params[:action]
                when 'update' then 'edit'
                when 'create' then 'new'
                when 'bulk_create' then 'advertising_costs'
                else params[:action]
                end
    end

    def i18n_translate(type, key = nil)
      key ||= i18n_key

      defaults = []
      if parent
        defaults << :"e9.e9_crm.dated_costs.#{parent_class.model_name.collection}.#{key}_#{type}"
      end

      # TODO why isn't this being picked up?
      defaults << :"e9.e9_crm.dated_costs.#{key}_#{type}"

      I18n.t(defaults.shift, :default => defaults, :parent => parent && parent.name)
    end

    def default_ordered_on
      'date'
    end

    def default_ordered_dir
      'ASC'
    end

    def determine_layout
      if request.xhr?
        false
      elsif params[:print]
        'print'
      else
        super
      end
    end

end
