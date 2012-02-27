class AddMetaFieldsToContentView < ActiveRecord::Migration
  def self.up
    add_column :content_views, :meta_keywords, :text
  end

  def self.down
    remove_column :content_views, :meta_keywords
  end
end
