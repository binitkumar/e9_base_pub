class AddThumbMountToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :thumb, :string
  end

  def self.down
    remove_column :content_views, :thumb
  end
end
