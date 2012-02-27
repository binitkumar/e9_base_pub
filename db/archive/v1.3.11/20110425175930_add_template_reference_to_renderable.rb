class AddTemplateReferenceToRenderable < ActiveRecord::Migration
  def self.up
    add_column :renderables, :template_id, :integer rescue nil
  end

  def self.down
    remove_column :renderables, :template_id rescue nil
  end
end
