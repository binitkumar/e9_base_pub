class RemovalOfSiteConfigurations < ActiveRecord::Migration
  def self.up
    begin
      drop_table :site_configurations

      add_column :settings, :favicon, :string
      add_column :settings, :default_avatar, :string
      add_column :settings, :default_content_icon, :string
    rescue => e
    end
  end

  def self.down
  end
end
