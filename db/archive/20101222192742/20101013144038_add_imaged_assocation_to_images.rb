class AddImagedAssocationToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :imaged_type, :string
    add_column :images, :imaged_id, :integer
  end

  def self.down
    remove_column :images, :imaged_id
    remove_column :images, :imaged_type
  end
end
