class ImageSpecBecomesRenderable < ActiveRecord::Migration
  def self.up
    drop_table :image_specs

    add_column :renderables, :width,  :integer
    add_column :renderables, :height, :integer
  end

  def self.down
    remove_column :renderables, :width
    remove_column :renderables, :height

    create_table :image_specs, :force => true do |t|
      t.integer :width, :height
      t.references :layout
      t.string :name
      t.timestamps
    end
  end
end
