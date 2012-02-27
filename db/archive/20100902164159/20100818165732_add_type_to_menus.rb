class AddTypeToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :type, :string
  end

  def self.down
    remove_column :menus, :type
  end
end
