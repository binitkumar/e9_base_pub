class SystemBooleanToLayout < ActiveRecord::Migration
  def self.up
    add_column :layouts, :system, :boolean, :default => false
  end

  def self.down
    remove_column :layouts, :system
  end
end
