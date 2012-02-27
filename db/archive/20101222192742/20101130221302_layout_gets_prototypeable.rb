class LayoutGetsPrototypeable < ActiveRecord::Migration
  def self.up
    add_column :layouts, :prototypeable, :boolean, :default => false
  end

  def self.down
    remove_column :layouts, :prototypeable
  end
end
