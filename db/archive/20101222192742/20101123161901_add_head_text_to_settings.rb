class AddHeadTextToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :header_text, :text
  end

  def self.down
    remove_column :settings, :header_text
  end
end
