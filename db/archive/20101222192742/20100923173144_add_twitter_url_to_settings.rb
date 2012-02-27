class AddTwitterUrlToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :twitter_company_page_url, :string
  end

  def self.down
    remove_column :settings, :twitter_company_page_url
  end
end
