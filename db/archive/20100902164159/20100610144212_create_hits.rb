class CreateHits < ActiveRecord::Migration
  def self.up
    create_table :hits do |t|
      t.references :hittable, :polymorphic => true
      t.date :created_date
      t.timestamps
    end
  end

  def self.down
    drop_table :hits
  end
end
