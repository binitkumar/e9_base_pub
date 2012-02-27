class AddLayoutPreviewToLayout < ActiveRecord::Migration
  def self.up
    add_column :layouts, :layout_preview, :string
  end

  def self.down
    remove_column :layouts, :layout_preview
  end
end
