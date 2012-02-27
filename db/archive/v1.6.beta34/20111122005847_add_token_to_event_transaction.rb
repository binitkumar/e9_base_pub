class AddTokenToEventTransaction < ActiveRecord::Migration
  def self.up
    add_column :event_transactions, :token, :string
  end

  def self.down
    remove_column :event_transactions, :token
  end
end
