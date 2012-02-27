class Admin::UserEmailsController < Admin::EmailsController

  filter_access_to :select, :personalize, :require => :read, :context => :admin

  respond_to :json, :only => :personalize
  respond_to :html, :except => :personalize

  has_scope :of_sub_type, :as => :type, :only => [:index, :select]
  has_scope :inactive, :only => :index, :type => :boolean
  has_scope :active,   :only => :index, :type => :boolean, :default => proc {|c| c.params[:inactive].blank? }

  def select
    index! do |format|
      format.html { render :layout => !request.xhr? }
    end
  end

  def personalize
    unless params[:contact_id] =~ /\d+/ && @contact = Contact.find_by_id(params[:contact_id])
      head :status => 404
    else
      object = resource
      object.send_grid = false

      if resource_params = params[resource_instance_name]
        object.attributes = resource_params
      end

      object.recipient = params[:user_id] =~ /\d+/ && 
                           @contact.users.find_by_id(params[:user_id]) || 
                           @contact.primary_user

      render :json => object
    end
  end

  protected

  def ordered_if
    %w(index select).member? params[:action]
  end

  def add_index_breadcrumb
    add_breadcrumb e9_t(:index_title), :admin_user_emails_url
  end

  def mailing_list_name
    params[:id] && resource.mailing_list.try(:name) || 'the list'
  end

  def interpolation_options
    { :target => params[:test] && current_user.email || mailing_list_name }
  end

  def collection_scope
    super.scoped.
      select('emails.*, mailing_lists.name mailing_list_name').
      joins('left outer join mailing_lists on emails.mailing_list_id = mailing_lists.id and emails.sub_type = "newsletter"')
  end
end
