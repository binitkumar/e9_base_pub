class CreatePartials < ActiveRecord::Migration
  def self.up
    add_column :renderables, :file, :text
  end

  def self.down
    remove_column :renderables, :file
  end
end
