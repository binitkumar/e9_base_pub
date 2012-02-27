class RemoveExpandMenus < ActiveRecord::Migration
  def self.up
    remove_column :region_types, :expand_menus
  end

  def self.down
    add_column :region_types, :expand_menus, :string, :default => 'always'
  end
end
