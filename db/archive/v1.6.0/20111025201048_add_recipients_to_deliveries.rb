class AddRecipientsToDeliveries < ActiveRecord::Migration
  def self.up
    add_column :email_deliveries, :recipients, :text
  end

  def self.down
    remove_column :email_deliveries, :recipients
  end
end
