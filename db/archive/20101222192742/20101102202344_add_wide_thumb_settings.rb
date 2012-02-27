class AddWideThumbSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :wide_thumb_width, :integer
    add_column :settings, :wide_thumb_height, :integer
  end

  def self.down
    remove_column :settings, :wide_thumb_height
    remove_column :settings, :wide_thumb_width
  end
end
