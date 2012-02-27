class ChangeUserStatusToString < ActiveRecord::Migration
  def self.up
    change_column :users, :status, :string, :limit => 32
  end

  def self.down
    change_column :useres, :status, :integer, :limit => 1, :default => 1
  end
end
