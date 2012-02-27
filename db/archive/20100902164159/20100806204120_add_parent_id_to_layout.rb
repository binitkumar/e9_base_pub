class AddParentIdToLayout < ActiveRecord::Migration
  def self.up
    add_column :layouts, :parent_id, :integer
  end

  def self.down
    remove_column :layouts, :parent_id
  end
end
