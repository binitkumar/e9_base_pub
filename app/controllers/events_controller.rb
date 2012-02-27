class EventsController < InheritedResources::Base
  include PublicFacingController

  actions :show

  has_scope :event_type, :only => :index

  has_scope :future,     :type => :boolean, :default => true, :only => :index
  has_scope :ordered,    :type => :boolean, :default => true, :only => :index
  
  filter_access_to :show, :attribute_check => true, 
                   :load_method => :resource, :context => :pages, :require => :read

  add_resource_breadcrumbs
  before_filter :add_success_breadcrumb, :only => :success

  respond_to :json, :only => :show

  protected

    def pagination_per_page_default 
      E9::Config[:blog_pagination_records]
    end

    def collection_scope
      end_of_association_chain.for_roleable(current_user_or_public_role).published
    end

    def collection
      get_collection_ivar || begin
        objects = collection_scope.paginate(pagination_parameters)

        set_collection_ivar objects
      end
    end

    def resource
      get_resource_ivar || begin
        object = collection_scope.find_by_permalink!(params[:id]).tap do |event|
          event.increment_hits!
        end

        set_resource_ivar object
      end
    end

    def add_index_breadcrumb
      @index_title = (events_page || find_current_page).title

      add_breadcrumb! @index_title, events_path

      if params[:event_type] && @event_type = EventType.find_by_permalink!(params[:event_type])
        @index_title << ": #{@event_type.name}"
      end
    end

    def add_success_breadcrumb
      add_breadcrumb! e9_t(:success_breadcrumb)
    end

    def find_current_page
      @current_page = if params[:id]
        resource
      elsif events_page
        events_page
      else
        super
      end
    end

    def events_page
      @_events_page ||= LinkableSystemPage.find_by_identifier(Page::Identifiers::EVENTS)
    end

end
