class AddMenuTruncationLengthToConfig < ActiveRecord::Migration
  def self.up
    add_column :settings, :default_menu_truncation, :integer
  end

  def self.down
    remove_column :settings, :default_menu_truncation
  end
end
