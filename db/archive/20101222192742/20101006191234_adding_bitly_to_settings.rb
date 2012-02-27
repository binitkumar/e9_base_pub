class AddingBitlyToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :bitly_username, :string
    add_column :settings, :bitly_api_key, :string
  end

  def self.down
    remove_column :settings, :bitly_api_key
    remove_column :settings, :bitly_username
  end
end
