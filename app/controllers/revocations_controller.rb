class RevocationsController < Devise::RevocationsController
  include PublicFacingController

  before_filter :add_manage_account_breadcrumb

  protected

    def add_manage_account_breadcrumb
      add_breadcrumb! current_page.title
    end

    def find_current_page
      @current_page = 
        ContentView.find_by_identifier(Page::Identifiers::REVOKE) || SystemPage.master
    end

end
