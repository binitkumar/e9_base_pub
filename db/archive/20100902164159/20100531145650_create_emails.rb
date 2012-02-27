class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.references :mailing_list
      t.string :name, :type, :subject, :status, :identifier
      t.string :status, :default => 'p'
      t.string :to_email, :from_email, :reply_email
      t.text :html_body, :text_body
      t.date :delivery_date
      t.boolean :deletable, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
