class E9Crm::NotesController < E9Crm::ResourcesController
  defaults :resource_class => Note
  belongs_to :deal, :contact, :polymorphic => true, :optional => true

  respond_to :json, :only => [:show, :index, :create, :update]

  self.should_paginate_index = false

  has_scope :search, :only => :index
  has_scope :limit, :only => :index

  has_scope :active, :only => :index, :default => 'true' do |controller, scope, value|
    is_active = value.nil? || E9.true_value?(value)

    # NOTE set this so we can use it to determine the sort order
    controller.instance_variable_set(:@active, is_active)
    scope.active(is_active)
  end

  prepend_before_filter :only => :index do
    # On the initial page load, prepop the current user's contact_id
    unless request.xhr?
      params[:contact] ||= current_user.try(:contact_id)
    end
  end

  has_scope :by_contact, :as => :contact, :only => :index do |controller, scope, value|
    if contact = Contact.find_by_id(value)
      controller.instance_variable_set(:@by_contact, contact)
      scope.by_contact(contact)
    else
      scope
    end
  end
  
  has_scope :order, :only => :index, :default => '1' do |controller, scope, _|
    value = controller.params[:active]
    is_active = value.nil? || E9.true_value?(value)
    scope.order(is_active ? "notes.due_date ASC" : "notes.completed_at DESC")
  end

  before_filter :build_attachment, :only => [:new, :edit]

  after_filter :add_count_header_if_paging

  def create
    create! do |success, failure|
      success.html { redirect_to parent_or_collection_path }
      success.js { render :location => parent_or_collection_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to parent_or_collection_path }
      success.js { render :location => parent_or_collection_path }
    end
  end

  protected

    # Wrap update_resource in a rescue to protect against errors if the
    # user goes "back" in the browser after submitting a form, and deleting
    # nested resource attachments
    def update_resource(*args)
      super(*args)
    rescue ActiveRecord::RecordNotFound
      resource.errors.add(:base, :unknown)
    end

    def parent_or_collection_path
      if params[:commit_and_edit]
        edit_polymorphic_path(resource)
      elsif parent
        polymorphic_path(parent)
      elsif resource.completed?
        notes_path(:active => false)
      else
        notes_path
      end
    end

    def build_attachment
      object = params[:action] == 'new' ? build_resource : resource
      object.attachments.build
    end

    def add_count_header_if_paging
      if request.xhr? && params[:limit]
        response.headers['X-Note-Count'] = end_of_association_chain.except(:limit, :order).count.to_s
      end
    end

    def collection_scope
      # NOTE association_chain is called first to trigger the scopes
      scope = end_of_association_chain.includes(:note_assignments, 
                                                :owner, 
                                                :deals => :note_assignments, 
                                                :contacts => :note_assignments)
    end

    def resource_params
      super.tap do |rp|

        # prepop owner as current user
        rp[:contact_id] ||= begin
          current_user.create_contact_if_missing! && current_user.contact.id
        end

        # ensure empty arrays for deals/contacts in case none are passed
        # (to force the assocations that exist to be removed)
        rp[:deal_ids]    ||= []
        rp[:contact_ids] ||= []

        # force the inclusion of parent into the note's assigments on new
        # form requests
        if params[:action] == 'new'
          if @deal
            rp[:deal_ids] |= [@deal.id]
          elsif @contact
            rp[:contact_ids] |= [@contact.id]
          end
        end
      end
    end

    def add_index_breadcrumb
      if association_chain && parent?
        add_breadcrumb! parent.class.model_name.pluralize, parent.class
        add_breadcrumb! parent.name, polymorphic_path(parent)
      else
        add_breadcrumb! (@index_title = 'Dashboard'), notes_path
      end
    end

    def determine_layout
      request.xhr? ? false : super
    end

end
