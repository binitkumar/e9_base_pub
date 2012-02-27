class AddDisplayMoreInfoSettings < ActiveRecord::Migration
  def self.up
    add_column :content_views, :display_more_info, :boolean
    add_column :settings, :slide_display_more_info, :boolean
  end

  def self.down
    remove_column :settings, :slide_display_more_info
    remove_column :content_views, :display_more_info
  end
end
