class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :type, :title 
      t.text :details
      t.references :contact
      t.date :due_date
      t.boolean :completed, :default => false
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
