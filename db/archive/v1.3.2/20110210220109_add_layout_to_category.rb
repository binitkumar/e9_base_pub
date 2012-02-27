class AddLayoutToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :layout_id, :integer
  end

  def self.down
    remove_column :categories, :layout_id
  end
end
