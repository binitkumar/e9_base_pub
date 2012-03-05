class ProfilesController < ApplicationController
  include PublicFacingController
  inherit_resources
  defaults :instance_name => "user", :resource_class => User, :collection_name => "users"

  respond_to :html, :except => [:unsave_all]
  respond_to :js, :only => [:update, :unsave_all, :reset_avatar, :upload_avatar]

  before_filter :authenticate_user!

  add_resource_breadcrumbs :except => :show

  filter_access_to :all, :require => :update

  before_filter :initialize_mailing_list_ids, :only => :update

  def change_password
    render :layout => false
  end

  def update
    update! do |success, failure|
      success.html { redirect_to(:profile) }
    end
  end

  def unsave_all
    resource.favorites.destroy_all
    respond_with(resource)
  end

  protected

  def add_index_breadcrumb
    add_breadcrumb e9_t(:show_title), :profile_path
  end

  def find_current_page
    @current_page ||= begin
      identifier = case params[:action].to_sym
        when :edit, :update then Page::Identifiers::EDIT_PROFILE
        when :show          then Page::Identifiers::PROFILE
      end

      ContentView.find_by_identifier(identifier)
    end
  end

  def pagination_per_page_default
    E9::Config[:my_home_records_per_page]
  end

  # add blank mailing_list_ids for subscriptions
  def initialize_mailing_list_ids 
    if params[:user] && params[:update_mailing_lists]
      params[:user][:mailing_list_ids] ||= []
    end
  end

  def resource
    @user ||= current_user
  end

end
