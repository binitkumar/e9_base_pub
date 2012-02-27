class AddImageToLayout < ActiveRecord::Migration
  def self.up
    add_column :layouts, :image, :string
    add_column :settings, :layout_image_width, :integer
    add_column :settings, :layout_image_height, :integer
  end

  def self.down
    remove_column :settings, :layout_image_height
    remove_column :settings, :layout_image_width
    remove_column :layouts, :image
  end
end
