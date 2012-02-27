class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :title
      t.string :type
      t.string :role
      t.references :user
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :forums
    drop_table :faqs
  end
end
