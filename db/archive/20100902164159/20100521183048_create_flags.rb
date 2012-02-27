class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
      t.references :flaggable, :polymorphic => true
      t.references :user
      t.string :reason
      t.timestamps
    end
    add_index :flags, :user_id
  end

  def self.down
    drop_table :flags
  end
end
