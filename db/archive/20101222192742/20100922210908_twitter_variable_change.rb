class TwitterVariableChange < ActiveRecord::Migration
  def self.up
    add_column :settings, :twitter_secret_token, :string
  end

  def self.down
    remove_column :settings, :twitter_secret_token
  end
end
