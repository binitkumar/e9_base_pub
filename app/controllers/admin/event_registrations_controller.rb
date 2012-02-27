class Admin::EventRegistrationsController < Admin::ResourceController
  include E9::Controllers::Orderable

  belongs_to :event, :finder => :find_by_permalink!

  filter_access_to :transfer, :edit_voucher, :mark_attended, :require => :update, :context => :admin

  has_scope :by_transaction, :as => :transaction, :only => :index

  before_filter :load_contact_ids, :only => [:index, :mark_attended]

  add_resource_breadcrumbs

  respond_to :js

  def update
    update! do |format|
      format.html { redirect_to report_admin_events_path }
      format.js do 
        load_contact_ids
        render
      end
    end
  end

  def transfer
    edit!
  end

  def mark_attended
    end_of_association_chain.cancelled(false).update_all ['attended = ?', true]

    respond_to do |format|
      format.html { redirect_to :index }
      format.js { render :index }
    end
  end

  protected

    # Event registrations are only updateable through toggles and transferring 
    # between events, all JS.  We don't want to validate on toggling, only
    # on transfer (so you can't move a user to an event twice, mainly)
    def update_resource(object, attributes)
      object.attributes = attributes
      object.save :validate => object.event_id_changed?
    end

    def load_contact_ids
      @contact_ids ||= begin
        contact_id_sql = end_of_association_chain.
                           except(:order).
                           cancelled(false).
                           select('contacts.id').
                           joins(:user => :contact).
                           where('contacts.ok_to_email = ?', true).to_sql

        Contact.connection.send(:select_values, contact_id_sql, 'Contact ID Load')
      end
    end

    def add_index_breadcrumb
      @index_title = "Attendees for #{parent.title}"
      add_breadcrumb! 'Events', admin_events_path
      add_breadcrumb! 'Attendee Report'
    end

    def collection
      get_collection_ivar || begin
        scope = end_of_association_chain

        scope = scope.includes(:event_transaction => :campaign, :user => :contact)

        set_collection_ivar scope.all
      end
    end

    def default_ordered_dir
      'ASC'
    end

    def default_ordered_on
      'name'
    end

    def ordered_if
      %w(index mark_attended).member? params[:action]
    end

    def determine_layout
      request.xhr? ? false : super
    end

end
