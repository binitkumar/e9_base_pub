class CreateImageSpecs < ActiveRecord::Migration
  def self.up
    create_table :image_specs do |t|
      t.integer :width, :height
      t.references :layout
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :image_specs
  end
end
