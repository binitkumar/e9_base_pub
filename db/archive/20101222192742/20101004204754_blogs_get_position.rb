class BlogsGetPosition < ActiveRecord::Migration
  def self.up
    add_column :blogs, :position, :integer
  end

  def self.down
    remove_column :blogs, :position
  end
end
