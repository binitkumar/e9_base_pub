class LinkedInLinkToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :linked_in_company_page_url, :string
  end

  def self.down
    remove_column :settings, :linked_in_company_page_url
  end
end
