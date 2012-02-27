class AddDisplayActionsToContentViewSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :page_display_actions, :boolean
    add_column :settings, :blog_display_actions, :boolean
    add_column :settings, :slide_display_actions, :boolean
    add_column :content_views, :display_actions, :boolean
  end

  def self.down
    remove_column :content_views, :display_actions
    remove_column :settings, :slide_display_actions
    remove_column :settings, :blog_display_actions
    remove_column :settings, :page_display_actions
  end
end
