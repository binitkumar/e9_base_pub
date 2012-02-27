class ImageSpecGetsDefault < ActiveRecord::Migration
  def self.up
    add_column :image_specs, :default, :string
  end

  def self.down
    remove_column :image_specs, :default
  end
end
