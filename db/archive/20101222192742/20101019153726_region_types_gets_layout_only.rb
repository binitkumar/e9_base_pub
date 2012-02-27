class RegionTypesGetsLayoutOnly < ActiveRecord::Migration
  def self.up
    add_column :region_types, :layout_only, :boolean, :default => false
  end

  def self.down
    remove_column :region_types, :layout_only
  end
end
