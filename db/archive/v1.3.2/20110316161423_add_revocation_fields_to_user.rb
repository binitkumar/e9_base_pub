class AddRevocationFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :revocation_token, :string
    add_column :users, :revoked_at,       :datetime
  end

  def self.down
    remove_column :users, :revoked_at
    remove_column :users, :revocation_token
  end
end
