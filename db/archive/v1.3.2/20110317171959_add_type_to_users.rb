class AddTypeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :string, :default => User::Status::User
    User.reset_column_information
    User.update_all :status => User::Status::User
  end

  def self.down
    remove_column :users, :status
  end
end
