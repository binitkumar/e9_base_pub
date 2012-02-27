module PublicFacingController
  extend ActiveSupport::Concern

  def show_home_breadcrumb?
    true
  end
end
