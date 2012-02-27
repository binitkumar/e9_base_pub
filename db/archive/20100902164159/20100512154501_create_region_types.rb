class CreateRegionTypes < ActiveRecord::Migration
  def self.up
    create_table :region_types do |t|
      t.string  :name
      t.string  :domid
      t.string  :role
      t.string  :expand_menus,  :default => RegionType::ExpandMenus::ALWAYS
    end
    create_table :layouts_region_types, :id => false do |t|
      t.references :layout, :region_type
    end
  end

  def self.down
    drop_table :region_types
    drop_table :layouts_region_types
  end
end
