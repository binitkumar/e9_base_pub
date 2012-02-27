class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.references :renderable, :region
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
