class AddDimensionsToImageMount < ActiveRecord::Migration
  def self.up
    add_column :image_mounts, :width, :integer
    add_column :image_mounts, :height, :integer
  end

  def self.down
    remove_column :image_mounts, :height
    remove_column :image_mounts, :width
  end
end
