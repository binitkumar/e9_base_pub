class AddTwitterKeysToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :twitter_app_id, :string
    add_column :settings, :twitter_app_secret, :string
    add_column :settings, :twitter_access_token, :string
  end

  def self.down
    remove_column :settings, :twitter_access_token
    remove_column :settings, :twitter_app_secret
    remove_column :settings, :twitter_app_id
  end
end
