class AddingTimestamps < ActiveRecord::Migration
  def self.up
    add_column :menus, :created_at, :datetime
    add_column :menus, :updated_at, :datetime
  end

  def self.down
    remove_column :menus, :updated_at
    remove_column :menus, :created_at
  end
end
