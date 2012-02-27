class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :commentable, :polymorphic => true
      t.references :user
      t.string :title
      t.text :body
      t.boolean :deleted, :default => false
      t.references :deleter
      t.timestamps
    end
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
