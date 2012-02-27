class SubscriptionsController < ApplicationController
  include PublicFacingController
  inherit_resources
  actions :show, :update
  defaults :instance_name => "user", :resource_class => User

  respond_to :html, :js

  before_filter :add_show_breadcrumb

  before_filter :initialize_user_params, :only => :update

  def show
    # if the user is not found we're rendering with a new User with errors
    object = resource
    flash[:alert] = object.errors[:base].first
    show!
  end

  def update
    object = resource

    update_resource(object, params[:user])

    respond_with(object) do |format|
      format.html { render :show }
      format.js   { head :ok }
    end
  end

  protected

  def find_current_page
    @current_page ||= ContentView.find_by_identifier(Page::Identifiers::UNSUBSCRIBE)
  end

  #
  # The resource is the user but we resolve the user from the subscription's token.
  # This presents a problem as the form allows you to submit it multiple times and the
  # original subscription may be deleted.  Because of this the original subscription
  # token is stored on User, but only temporarily.  If subscription token is not set
  # on User it will expire on the next save.
  #
  def resource
    @user ||= begin
      # try to find the original subscription and return its User
      if subscription = Subscription.find_by_unsubscribe_token(params[:id])
        subscription.user(:include => :mailing_lists)

      # if it no longer exists, try to find its previously set User
      else
        User.find_by_subscriptions_token!(params[:id])
      end

    # otherwise return a new user with an error
    rescue ActiveRecord::RecordNotFound => e
      User.new.tap {|u| u.errors.add(:base, :invalid_unsubscribe_token) }

    # but always set @subscription_token from params, this is used to determine the form's url
    ensure
      @subscription_token = params[:id]
    end
  end

  def initialize_user_params
    params[:user] ||= {}

    params[:user][:mailing_list_ids] ||= []
    params[:user][:subscriptions_token] = params[:id]
  end

end
