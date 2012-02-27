module SiteMapHelper
  def google_site_map_xmlns
    'http://www.sitemaps.org/schemas/sitemap/0.9'
  end

  def changefreq(record)
    'daily'
  end

  def priority(record)
    0.8
  end
end
