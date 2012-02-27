class AddDefaultContentIconToConfig < ActiveRecord::Migration
  def self.up
    add_column :site_configurations, :default_content_icon, :string
  end

  def self.down
    remove_column :site_configurations, :default_content_icon
  end
end
