class CreateContentUpdates < ActiveRecord::Migration
  def self.up
    create_table :content_updates do |t|
      t.references :content, :polymorphic => true
      t.string :sub_content_type
      t.string :role
      t.timestamps
    end
  end

  def self.down
    drop_table :content_updates
  end
end
