class ContentViewGetsImage < ActiveRecord::Migration
  def self.up
    add_column :content_views, :image, :string
  end

  def self.down
    remove_column :content_views, :image
  end
end
