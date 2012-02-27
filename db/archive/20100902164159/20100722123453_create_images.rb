class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :file
      t.integer :height, :width
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
