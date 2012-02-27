class CreateMenuViews < ActiveRecord::Migration
  def self.up
    add_column :renderables, :menu_id, :integer
  end

  def self.down
    remove_column :renderables, :menu_id
  end
end
