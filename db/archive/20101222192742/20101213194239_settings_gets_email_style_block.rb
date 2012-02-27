class SettingsGetsEmailStyleBlock < ActiveRecord::Migration
  def self.up
    add_column :settings, :email_style_block, :text
  end

  def self.down
    remove_column :settings, :email_style_block
  end
end
