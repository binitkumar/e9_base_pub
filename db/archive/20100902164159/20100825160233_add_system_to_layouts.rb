class AddSystemToLayouts < ActiveRecord::Migration
  def self.up
    Layout.update_all ["system = ?", true], ["id in (?)", [1,2,3,4,5,6]]
    Layout.update_all ["role = ?", 'e9_user'], ["id in (?)", [1,3,4,5,6]]
  end

  def self.down
    Layout.update_all ["system = ?", false], ["id in (?)", [1,2,3,4,5,6]]
    Layout.update_all ["role = ?", 'guest'], ["id in (?)", [1,3,4,5,6]]
  end
end
