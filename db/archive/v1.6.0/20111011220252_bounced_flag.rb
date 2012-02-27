class BouncedFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :has_bounced, :boolean, :default => false
  end

  def self.down
    remove_column :users, :has_bounced
  end
end
