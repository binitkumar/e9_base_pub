class FriendEmailsController < InheritedResources::Base
  actions :new, :create

  before_filter :prepare_build_params, :only => :new
  before_filter :check_honeypot,       :only => [:create, :update]

  skip_after_filter :flash_to_headers, :if => :flash_is_error?
                                          
  respond_to :js
  respond_to :html, :only => :new

  def create
    create! do |success, failure|
      success.js { send_email(resource) && render }
    end
  end
 
  protected

  ##
  # reference to the system friend email
  #
  def friend_email
    @_friend_email ||= SystemEmail.friend_email
  end
  helper_method :friend_email

  ##
  # send the actual friend_email
  #
  def send_email(email)
    friend_email.send!(email.recipient_email, {
      :sender => email.sender || email.sender_email, 
      :message => email.message, 
      :page => email.linkable,
      :mail_args => {
        :cc => email.sender_email
      }
    })
  end

  #
  # 404s if there's no link in the params
  #
  def prepare_build_params
    begin
      params[:friend_email] ||= {}
      params[:friend_email][:link]   = Link.find(params[:link_id])
      params[:friend_email][:sender] = current_user
    rescue
      render_404
    end
  end

  def check_honeypot
    unless params[:friend_email] && params[:friend_email].delete(:email).blank?
      flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.create", :resource_name => 'Friend Email')
      respond_with(build_resource) do |format|
        format.js   { render }
        format.html { redirect_to(:root) }
      end
    end
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
