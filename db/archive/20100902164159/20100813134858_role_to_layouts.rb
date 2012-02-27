class RoleToLayouts < ActiveRecord::Migration
  def self.up
    add_column :layouts, :role, :string
  end

  def self.down
    remove_column :layouts, :role
  end
end
