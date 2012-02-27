class AddEmailSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :system_mailing_address, :string
    add_column :settings, :can_spam_mailing_address, :string
  end

  def self.down
    remove_column :settings, :can_spam_mailing_address
    remove_column :settings, :system_mailing_address
  end
end
