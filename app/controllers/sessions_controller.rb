class SessionsController < Devise::SessionsController
  include PublicFacingController

  before_filter :add_new_breadcrumb

  after_filter :clear_path_with_scope, :only => :destroy

  protected

  def find_current_page
    @current_page = ContentView.find_by_identifier(Page::Identifiers::SIGN_IN)
  end

  def determine_layout
    request.xhr? ? false : super
  end
end
