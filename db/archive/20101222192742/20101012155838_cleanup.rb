class Cleanup < ActiveRecord::Migration
  def self.up
    begin 
      drop_table :hard_links
      drop_table :soft_links
      drop_table :linkable_system_pages
      drop_table :preferences
    rescue
      # these aren't coming back
    end
  end

  def self.down
  end
end
