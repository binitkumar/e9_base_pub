class RenameImageTable < ActiveRecord::Migration
  def self.up
    rename_column :images, :imaged_type, :owner_type
    rename_column :images, :imaged_id, :owner_id
    add_column :images, :type, :string
    ActiveRecord::Base.connection.execute("UPDATE images SET type='Image'")
    rename_table :images, :attachments
  end

  def self.down
    rename_table :attachments, :images
    ActiveRecord::Base.connection.execute("DELETE FROM images WHERE type != 'Image'")
    remove_column :images, :type
    rename_column :images, :owner_id, :imaged_id
    rename_column :images, :owner_type, :imaged_type
  end
end
