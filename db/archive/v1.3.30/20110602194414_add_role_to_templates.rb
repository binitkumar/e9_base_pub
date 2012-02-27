class AddRoleToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :role, :string
  end

  def self.down
    remove_column :templates, :role
  end
end
