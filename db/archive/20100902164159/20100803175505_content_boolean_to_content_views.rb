class ContentBooleanToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :editable_content, :boolean, :default => true
  end

  def self.down
    remove_column :content_views, :editable_content
  end
end
