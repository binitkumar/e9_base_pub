class UpdatingMenus < ActiveRecord::Migration
  def self.up
    # handled by subclassing
    remove_column :menus, :hard_link

    # changed name to match new implementation
    rename_column :menus, :role_strict, :logged_out_only

    # obsolete, first system is "master"
    remove_column :menus, :master

    # obsolete, unused
    remove_column :menus, :page_id

    # icons merged to icon with css position swapping
    remove_column :menus, :hover_icon
    remove_column :menus, :selected_icon
    rename_column :menus, :off_icon, :icon

    # used for whether or not normal admin users can edit a menu
    add_column :menus, :editable, :boolean, :default => true
  end

  def self.down
    remove_column :menus, :editable
    rename_column :menus, :icon, :off_icon
    add_column :menus, :selected_icon, :string
    add_column :menus, :hover_icon, :string
    add_column :menus, :page_id, :integer
    add_column :menus, :master, :boolean, :default => false
    rename_column :menus, :logged_out_only, :role_strict
    add_column :menus, :hard_link, :boolean, :default => false
  end
end
