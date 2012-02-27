class AdminHelpSettingsChanges < ActiveRecord::Migration
  def self.up
    remove_column :settings, :e9_admin_help_page_url
    add_column :settings, :e9_standard_help, :text
    add_column :settings, :e9_custom_help, :text
  end

  def self.down
    remove_column :settings, :e9_custom_help
    remove_column :settings, :e9_standard_help
    add_column :settings, :e9_admin_help_page_url
  end
end
