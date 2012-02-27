class CreateSnippets < ActiveRecord::Migration
  def self.up
    add_column :renderables, :template, :text
    add_column :renderables, :revert_template, :text
  end

  def self.down
    remove_column :renderables, :revert_template
    remove_column :renderables, :template
  end
end
