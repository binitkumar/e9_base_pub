class AddIdentifierToRegionTypes < ActiveRecord::Migration
  def self.up
    add_column :region_types, :identifier, :string
    add_index "region_types", ["identifier"], :name => "index_region_types_on_identifier", :unique => true

    if banner_region = RegionType.find_by_name('Main Banner')
      banner_region.update_attribute(:identifier, 'banner_main')
    end
  end

  def self.down
    remove_column :region_types, :identifier
  end
end
