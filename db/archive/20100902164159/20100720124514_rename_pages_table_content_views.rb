class RenamePagesTableContentViews < ActiveRecord::Migration
  def self.up
    rename_table :pages, :content_views
  end

  def self.down
    rename_table :content_views, :pages
  end
end
