class AddSentColumnToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :sent_count, :integer
  end

  def self.down
    remove_column :emails, :sent_count
  end
end
