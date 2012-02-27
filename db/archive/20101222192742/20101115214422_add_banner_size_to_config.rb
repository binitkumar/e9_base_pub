class AddBannerSizeToConfig < ActiveRecord::Migration
  def self.up
    add_column :settings, :banner_width, :integer
    add_column :settings, :banner_height, :integer
  end

  def self.down
    remove_column :settings, :banner_height
    remove_column :settings, :banner_width
  end
end
