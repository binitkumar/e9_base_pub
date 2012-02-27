class SlideshowGetsDisplaySlideSelector < ActiveRecord::Migration
  def self.up
    add_column :categories, :display_slide_selector, :boolean, :default => true
  end

  def self.down
    remove_column :categories, :display_slide_selector
  end
end
