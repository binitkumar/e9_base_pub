class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :store_location, :only => :index

  self.route_scope = :admin

  filter_access_to :all, :context => :admin

  before_filter :add_admin_breadcrumb

  protected

  def add_admin_breadcrumb
    add_breadcrumb e9_t(:admin_breadcrumb), :admin_path
  end

  def add_index_breadcrumb
    args = [e9_t(:index_title)]
    args << polymorphic_path([:admin, resource_class]) if respond_to?(:resource_class)

    add_breadcrumb! *args
  end

  def find_current_page
    @current_page ||= ContentView.find_by_identifier(Page::Identifiers::ADMIN)
  end

  def pagination_per_page_default
    E9::Config[:admin_records_per_page]
  end

  def permission_denied_fallback_url
    if !current_user
      new_user_session_url
    elsif current_user.role.includes?('administrator')
      notes_url
    else
      super
    end
  end
end
