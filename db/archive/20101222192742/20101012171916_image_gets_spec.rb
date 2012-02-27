class ImageGetsSpec < ActiveRecord::Migration
  def self.up
    add_column :images, :image_spec_id, :integer
  end

  def self.down
    remove_column :images, :image_spec_id
  end
end
