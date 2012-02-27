class AddCssClassColumnToContentView < ActiveRecord::Migration
  def self.up
    rename_column :content_views, :author_string, :custom_css_classes
  end

  def self.down
    rename_column :content_views, :custom_css_classes, :author_string
  end
end
