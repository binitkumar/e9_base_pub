class RemoveDimensionsFromImage < ActiveRecord::Migration
  def self.up
    remove_column :images, :height
    remove_column :images, :width
  end

  def self.down
    add_column :images, :width, :integer
    add_column :images, :height, :integer
  end
end
