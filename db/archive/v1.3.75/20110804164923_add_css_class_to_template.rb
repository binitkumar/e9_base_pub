class AddCssClassToTemplate < ActiveRecord::Migration
  def self.up
    add_column :templates, :css_class, :string
  end

  def self.down
    remove_column :templates, :css_class
  end
end
