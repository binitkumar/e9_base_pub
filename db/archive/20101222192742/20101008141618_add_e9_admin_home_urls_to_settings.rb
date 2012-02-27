class AddE9AdminHomeUrlsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :e9_admin_home_blog_url, :string
    add_column :settings, :e9_admin_home_page_url, :string
  end

  def self.down
    remove_column :settings, :e9_admin_home_page_url
    remove_column :settings, :e9_admin_home_blog_url
  end
end
