class AddIdentifierToRenderables < ActiveRecord::Migration
  def self.up
    add_column :renderables, :identifier, :string
  end

  def self.down
    remove_column :renderables, :identifier
  end
end
