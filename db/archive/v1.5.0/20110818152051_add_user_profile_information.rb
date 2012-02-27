class AddUserProfileInformation < ActiveRecord::Migration
  def self.up
    add_column :users, :dob, :date
    add_column :users, :title, :string
    add_column :users, :company, :string
    add_column :users, :bio, :text
  end

  def self.down
    remove_column :users, :bio
    remove_column :users, :company
    remove_column :users, :title
    remove_column :users, :dob
  end
end
