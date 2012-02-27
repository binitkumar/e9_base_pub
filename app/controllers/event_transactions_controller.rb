class EventTransactionsController < InheritedResources::Base
  include PublicFacingController
  include E9::Controllers::CheckboxCaptcha

  belongs_to :event, :finder => :find_by_permalink!

  actions :new, :create, :show

  respond_to :js, :only => :create

  add_resource_breadcrumbs

  def create
    create! do |success, failure|
      success.js { render :location => event_event_transaction_url(parent, resource) }
    end
  end

  protected

    def method_for_find
      :find_by_token!
    end

    def add_index_breadcrumb
      add_breadcrumb! 'Events', events_path
    end

    def add_show_breadcrumb
      add_breadcrumb! e9_t(:show_breadcrumb)
    end

    def build_resource
      get_resource_ivar || begin
        object = end_of_association_chain.build(resource_params || {})

        # build the first event registration form
        if object.event_registrations.empty?
          object.event_registrations.build(event_registration_params)
        end

        set_resource_ivar(object)
      end
    end

    def create_resource(object)
      object.campaign = tracking_campaign
      object.save
    rescue EventTransaction::PaymentError => e
      return false
    end

    def event_registration_params
      {}.tap do |hash|
        hash[:event] = parent

        if current_user
          hash[:email] ||= current_user.email
          hash[:name]  ||= current_user.first_name
        end
      end
    end

    def collection_scope
      end_of_association_chain
    end

    def determine_layout
      request.xhr? ? false : super
    end

    def find_current_page
      @current_page = if params[:action] == 'show'
        parent
      else
        super
      end
    end

end
