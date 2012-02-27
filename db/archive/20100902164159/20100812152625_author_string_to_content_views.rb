class AuthorStringToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :author_string, :string
  end

  def self.down
    remove_column :content_views, :author_string
  end
end
