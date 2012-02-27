class AlterDatedCosts < ActiveRecord::Migration
  def self.up
    add_column :dated_costs, :deal_id, :integer
    add_column :dated_costs, :label, :string
  end

  def self.down
    remove_column :dated_costs, :label
    remove_column :dated_costs, :deal_id
  end
end
