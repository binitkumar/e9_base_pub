class AddUserIdToEventRegistration < ActiveRecord::Migration
  def self.up
    add_column :event_registrations, :user_id, :integer

    EventRegistration.reset_column_information

    EventRegistration.all.each do |er|
      unless er.user
        if user = User.find_by_email(er.email) || er.contact && er.contact.primary_user
          er.user = user
          er.save(:validate => false)
        else
          puts "Missing user for #{er.id} - #{er.email}"
        end
      end
    end
  end

  def self.down
    remove_column :event_registrations, :user_id
  end
end
