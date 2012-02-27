class MailingListDescriptionBecomesString < ActiveRecord::Migration
  def self.up
    change_column :mailing_lists, :description, :string
  end

  def self.down
    change_column :mailing_lists, :description, :text
  end
end
