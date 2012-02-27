class AddPermalinkToForums < ActiveRecord::Migration
  def self.up
    add_column :categories, :permalink, :string
    add_index :categories, ["permalink"], :name => "index_categories_on_permalink", :unique => true
  end

  def self.down
    remove_index :categories, :name => "index_categories_on_permalink"
    remove_column :categories, :permalink
  end
end
