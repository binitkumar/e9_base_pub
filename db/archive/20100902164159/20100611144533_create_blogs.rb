class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :title, :role, :slug
      t.text :description
      t.references :user
      t.timestamps
      t.boolean :master, :default => false
    end
    add_index :blogs, :slug, :unique => true
  end

  def self.down
    drop_table :blogs
  end
end
