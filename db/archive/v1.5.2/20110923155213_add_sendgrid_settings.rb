class AddSendgridSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :smtp_username, :string
    add_column :settings, :smtp_password, :string
    add_column :settings, :smtp_domain, :string
    add_column :settings, :smtp_url, :string
  end

  def self.down
    remove_column :settings, :smtp_url
    remove_column :settings, :smtp_domain
    remove_column :settings, :smtp_password
    remove_column :settings, :smtp_username
  end
end
