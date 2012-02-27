class AddPermalinkToEventType < ActiveRecord::Migration
  def self.up
    add_column :event_types, :permalink, :string
  end

  def self.down
    remove_column :event_types, :permalink
  end
end
