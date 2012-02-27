class AddIndexToPageViewsSession < ActiveRecord::Migration
  def self.up
    add_index :page_views, :session
  end

  def self.down
    remove_index :page_views, :column => :session
  end
end
