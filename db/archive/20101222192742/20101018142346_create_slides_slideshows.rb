class CreateSlidesSlideshows < ActiveRecord::Migration
  def self.up
    create_table :slideshow_assignments, :force => true do |t|
      t.references :slide, :slideshow
      t.integer :position
    end
  end

  def self.down
    drop_table :slideshow_assignments
  end
end
