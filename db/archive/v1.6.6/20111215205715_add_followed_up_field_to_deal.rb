class AddFollowedUpFieldToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :followed_up, :boolean, :default => false
  end

  def self.down
    remove_column :deals, :followed_up
  end
end
