class LayoutGetsImageSpec < ActiveRecord::Migration
  def self.up
    add_column :renderables, :layout_id, :integer
  end

  def self.down
    remove_column :renderables, :layout_id
  end
end
