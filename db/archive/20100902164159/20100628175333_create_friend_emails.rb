class CreateFriendEmails < ActiveRecord::Migration
  def self.up
    create_table :friend_emails do |t|
      t.references :user
      t.references :link
      t.string :recipient_email, :sender_email
      t.text :message
      t.timestamps
    end
  end

  def self.down
    drop_table :friend_emails
  end
end
