class AddUnsubTokenToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :unsubscribe_token, :string
    add_index :subscriptions, :unsubscribe_token, :unique => true
  end

  def self.down
    remove_index :subscriptions, :column => :unsubscribe_token
    remove_column :subscriptions, :unsubscribe_token
  end
end
