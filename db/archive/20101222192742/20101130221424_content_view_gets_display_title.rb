class ContentViewGetsDisplayTitle < ActiveRecord::Migration
  def self.up
    add_column :content_views, :display_title, :boolean, :default => true
  end

  def self.down
    remove_column :content_views, :display_title
  end
end
