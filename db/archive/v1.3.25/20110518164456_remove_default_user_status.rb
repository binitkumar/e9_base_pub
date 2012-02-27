class RemoveDefaultUserStatus < ActiveRecord::Migration
  def self.up
    change_column :users, :status, :string, :limit => 32, :default => nil
    User.update_all ["status = ?", User::Status::User],     "status = '1'"
    User.update_all ["status = ?", User::Status::Prospect], "status = '0'"
  end

  def self.down
    change_column :users, :status, :string, :limit => 32, :default => '1'
    User.update_all "status = '0'", ["status = ?", User::Status::Prospect]
    User.update_all "status = '1'", ["status = ?", User::Status::User]
  end
end
