class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.references :view, :polymorphic => true
      t.references :region_type
      t.string  :name
      t.string  :domid
      t.timestamps
    end
  end

  def self.down
    drop_table :regions
  end
end
