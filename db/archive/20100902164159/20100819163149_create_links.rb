class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.references :linkable, :polymorphic => true
      t.string :sub_linkable_type
      t.string :role

      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
