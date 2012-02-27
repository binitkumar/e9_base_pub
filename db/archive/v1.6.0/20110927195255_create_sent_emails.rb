class CreateSentEmails < ActiveRecord::Migration
  def self.up
    create_table :email_deliveries do |t|
      t.references :campaign, :email
      t.string :subject, :to, :from, :reply_to, :formats
      t.text :message, :html_body, :text_body, :contact_ids
      t.integer :requests
      t.timestamps
    end
  end

  def self.down
    drop_table :email_deliveries
  end
end
