class CreateEventRegistrations < ActiveRecord::Migration
  def self.up
    create_table :event_registrations do |t|
      t.references :contact, :event_transaction, :event
      t.string :email, :name, :promo_code
      t.text :details
      t.boolean :attended, :default => false
      t.boolean :cancelled, :default => false
      t.integer :paid

      t.timestamps
    end
  end

  def self.down
    drop_table :event_registrations
  end
end
