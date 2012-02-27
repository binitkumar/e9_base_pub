module Admin::BannersHelper
  def manage_admin_banner_link(banner)
    link_to e9_t(:manage), manage_admin_banner_path(banner)
  end
end
