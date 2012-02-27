class SlidePaginationSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :slide_pagination_records, :integer
  end

  def self.down
    remove_column :settings, :slide_pagination_records
  end
end
