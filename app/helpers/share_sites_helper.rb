module ShareSitesHelper
  def share_site_link(share_site, options = {})
    page = options[:page] || current_page

    return '' unless page.present?

    link_id   = "share-site-#{share_site.id}"
    link_text = e9_t(:share_site_link, :share_site_name => share_site.name)

    link_to(link_text,
            share_site.prepare_url(page),
            :title => e9_t(:share_site_title, :share_site_name => share_site.name),
            :rel   => "share-site external",
            :alt   => link_text,
            :title => link_text,
            :id    => link_id,
            :class => "icon i#{share_site.icon_index}")
  end
end
