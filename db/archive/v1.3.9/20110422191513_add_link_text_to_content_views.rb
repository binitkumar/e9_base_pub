class AddLinkTextToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :link_text, :string
  end

  def self.down
    remove_column :content_views, :link_text
  end
end
