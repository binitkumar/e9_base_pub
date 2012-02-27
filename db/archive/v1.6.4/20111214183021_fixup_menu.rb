class FixupMenu < ActiveRecord::Migration
  def self.up
    remove_column :menus, :depth
    remove_column :menus, :path_pattern
    remove_column :menus, :toggle_eval

    add_column :menus, :show_children, :boolean, :default => true
  end

  def self.down
    remove_column :menus, :show_children

    add_column :menus, :toggle_eval, :string
    add_column :menus, :path_pattern, :string
    add_column :menus, :depth, :integer
  end
end
