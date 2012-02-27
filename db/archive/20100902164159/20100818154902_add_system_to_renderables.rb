class AddSystemToRenderables < ActiveRecord::Migration
  def self.up
    add_column :renderables, :system, :boolean, :default => false
  end

  def self.down
    add_column :renderables, :system, :boolean, :default => false
  end
end
