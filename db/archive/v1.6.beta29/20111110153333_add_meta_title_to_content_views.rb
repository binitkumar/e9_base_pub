class AddMetaTitleToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :meta_title, :string
  end

  def self.down
    remove_column :content_views, :meta_title
  end
end
