class RegistrationsController < Devise::RegistrationsController
  include PublicFacingController

  def self.resource_class; User end
  include E9::Controllers::Recaptcha

  prepend_before_filter :check_honeypot, :only => :create
  before_filter :add_new_breadcrumb
  before_filter :ensure_mailing_list_array, :only => :create

  respond_to :html, :js

  def create
    build_resource

    if resource.save
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end

  protected

  def find_current_page
    @current_page = ContentView.find_by_identifier(Page::Identifiers::SIGN_UP)
  end

  def set_resource_ivar(record)
    @user = record
  end

  def build_resource(hash = nil)
    resource || begin
      hash ||= params[resource_name] || {}

      if hash[:email] && prospect = User.prospects.where(:email => hash[:email]).first
        self.resource = prospect.tap {|u| u.attributes = hash }.to_user
      else
        self.resource = User.new(hash)
      end
    end
  end

  def check_honeypot
    unless params[resource_name].delete(:user_email).blank?
      flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.create", :resource_name => resource_name)
      respond_with(build_resource) do |format|
        format.html { redirect_to :root }
        format.js { head :ok }
      end
    end
  end

  def determine_layout
    request.xhr? ? false : super
  end

  def ensure_mailing_list_array
    params[:user][:mailing_list_ids] ||= []
  end
end
