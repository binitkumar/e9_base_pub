class CreateLinkableSystemPages < ActiveRecord::Migration
  def self.up
    create_table :linkable_system_pages do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :linkable_system_pages
  end
end
