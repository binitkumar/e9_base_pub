class PasswordsController < Devise::PasswordsController
  include PublicFacingController
  add_resource_breadcrumbs :except => :index

  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions

      redirect_to new_session_path(resource_name)
    else
      render_with_scope :new
    end
  end

  protected

  def find_current_page
    @current_page ||= ContentView.find_by_identifier(Page::Identifiers::PASSWORDS) || SystemPage.master
  end
end
