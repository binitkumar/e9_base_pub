class AddPatternMatchToMenu < ActiveRecord::Migration
  def self.up
    add_column :menus, :path_pattern, :string
  end

  def self.down
    remove_column :menus, :path_pattern
  end
end
