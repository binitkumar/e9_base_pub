class AddEventRegistrationText < ActiveRecord::Migration
  def self.up
    add_column :content_views, :event_registration_message, :text
  end

  def self.down
    remove_column :content_views, :event_registration_message
  end
end
