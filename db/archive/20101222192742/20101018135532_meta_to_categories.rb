class MetaToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :meta_description, :text
    add_column :categories, :meta_keywords, :text
  end

  def self.down
    remove_column :categories, :meta_keywords
    remove_column :categories, :meta_description
  end
end
