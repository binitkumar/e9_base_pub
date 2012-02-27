class CreateLayouts < ActiveRecord::Migration
  def self.up
    create_table :layouts do |t|
      t.string :identifier
      t.string :name
      t.string :template
      t.string :preview
      t.timestamps
    end
  end

  def self.down
    drop_table :layouts
  end
end
