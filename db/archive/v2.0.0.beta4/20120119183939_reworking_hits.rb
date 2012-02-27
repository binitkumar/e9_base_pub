class ReworkingHits < ActiveRecord::Migration
  def self.up
    add_column :content_views, :hit_count, :integer, :default => 0
    add_column :content_views, :hit_date, :date
  end

  def self.down
    remove_column :content_views, :hit_date
    remove_column :content_views, :hit_count
  end
end
