class AddUserPageIdToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :user_page_id, :integer
  end

  def self.down
    remove_column :campaigns, :user_page_id
  end
end
