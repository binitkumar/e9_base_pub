class AdminHelpUrlToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :e9_admin_help_page_url, :string
  end

  def self.down
    remove_column :settings, :e9_admin_help_page_url
  end
end
