class CreateMailingLists < ActiveRecord::Migration
  def self.up
    create_table :mailing_lists do |t|
      t.string :name, :identifier, :role
      t.text :description
      t.integer :subscriptions_count, :default => 0
      t.boolean :system, :default => false
      t.boolean :newsletter, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :mailing_lists
  end
end
