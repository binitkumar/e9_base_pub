class EmailStatusChange < ActiveRecord::Migration
  def self.up
    change_column :emails, :status, :boolean, :default => true
    rename_column :emails, :status, :active
    add_column    :emails, :sub_type, :string
    remove_column :emails, :deletable
    rename_column :emails, :from_email, :from
    rename_column :emails, :to_email, :to
    rename_column :emails, :reply_email, :reply_to
    remove_column :emails, :sent_count

    Email.reset_column_information
    UserEmail.update_all "sub_type = 'newsletter'"
  end

  def self.down
    add_column    :emails, :sent_count, :integer
    rename_column :emails, :reply_to, :reply_email
    rename_column :emails, :to, :to_email
    rename_column :emails, :from, :from_email
    add_column    :emails, :deletable, :boolean, :default => true
    remove_column :emails, :sub_type
    rename_column :emails, :active, :status
    change_column :emails, :status, :string, :default => 'p'
  end
end
