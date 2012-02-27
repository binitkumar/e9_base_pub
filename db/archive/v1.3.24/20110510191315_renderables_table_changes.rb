class RenderablesTableChanges < ActiveRecord::Migration
  def self.up
    remove_column :renderables, :identifier
    rename_column :renderables, :menu_id, :associated_id
    change_column :renderables, :file, :string
    add_column    :renderables, :options, :text
  end

  def self.down
    remove_column :renderables, :options, :text
    change_column :renderables, :file, :text, :limit => 255
    rename_column :renderables, :menu_id, :associated_id
    add_column    :renderables, :identifier, :string
  end
end
