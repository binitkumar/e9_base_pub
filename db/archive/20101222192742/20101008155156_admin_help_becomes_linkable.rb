class AdminHelpBecomesLinkable < ActiveRecord::Migration
  def self.up
    if page = ContentView.find_by_identifier(Page::Identifiers::ADMIN_HELP)
      page.permalink  = "admin/help"
      page.role       = "administrator"
      page['type']    = "LinkableSystemPage"
      page.save(:validate => false)
    end
  end

  def self.down
    if page = ContentView.find_by_identifier(Page::Identifiers::ADMIN_HELP)
      page.permalink  = nil
      page.role       = "e9_user"
      page['type']    = "SystemPage"
      page.save(:validate => false)
    end
  end
end
