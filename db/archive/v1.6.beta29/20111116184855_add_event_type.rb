class AddEventType < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.integer :position
      t.string :name
      t.text :form_html
    end
  end

  def self.down
    drop_table :event_types
  end
end
