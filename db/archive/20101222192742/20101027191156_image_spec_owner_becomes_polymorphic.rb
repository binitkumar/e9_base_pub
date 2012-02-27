class ImageSpecOwnerBecomesPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :renderables, :layout_id,  :owner_id
    add_column    :renderables, :owner_type, :string
  end

  def self.down
    remove_column :renderables, :owner_type
    rename_column :renderables, :owner_id,  :layout_id
  end
end
