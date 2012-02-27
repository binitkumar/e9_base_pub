class AddContactIdToDatedCost < ActiveRecord::Migration
  def self.up
    add_column :dated_costs, :credit, :boolean, :default => false
    add_column :dated_costs, :contact_id, :integer
  end

  def self.down
    remove_column :dated_costs, :contact_id
    remove_column :dated_costs, :credit
  end
end
