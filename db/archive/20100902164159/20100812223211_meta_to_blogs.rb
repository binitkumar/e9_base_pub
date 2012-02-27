class MetaToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :meta_description, :text
    add_column :blogs, :meta_keywords, :text
  end

  def self.down
    remove_column :blogs, :meta_keywords
    remove_column :blogs, :meta_description
  end
end
