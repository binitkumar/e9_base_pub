class AddUnsubTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :subscriptions_token, :string
  end

  def self.down
    remove_column :users, :subscriptions_token
  end
end
