class CanSpamIsText < ActiveRecord::Migration
  def self.up
    change_column :settings, :can_spam_mailing_address, :text
  end

  def self.down
    change_column :settings, :can_spam_mailing_address, :string
  end
end
