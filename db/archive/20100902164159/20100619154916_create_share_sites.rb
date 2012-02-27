class CreateShareSites < ActiveRecord::Migration
  def self.up
    create_table :share_sites do |t|
      t.string :name
      t.text :url
      t.integer :position
      t.boolean :enabled, :default => true
      t.integer :icon_index

      t.timestamps
    end
  end

  def self.down
    drop_table :share_sites
  end
end
