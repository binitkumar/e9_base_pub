class AddThumbToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :thumb, :string
  end

  def self.down
    remove_column :categories, :thumb
  end
end
