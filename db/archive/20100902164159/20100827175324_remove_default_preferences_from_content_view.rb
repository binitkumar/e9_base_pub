class RemoveDefaultPreferencesFromContentView < ActiveRecord::Migration
  def self.up
    change_column :content_views, :display_social_bookmarks, :boolean, :default => nil
    change_column :content_views, :display_date,             :boolean, :default => nil
    change_column :content_views, :display_author_info,      :boolean, :default => nil
    change_column :content_views, :display_labels,           :boolean, :default => nil
    change_column :content_views, :allow_comments,           :boolean, :default => nil
  end

  def self.down
    change_column :content_views, :display_social_bookmarks, :boolean, :default => true
    change_column :content_views, :display_date,             :boolean, :default => true
    change_column :content_views, :display_author_info,      :boolean, :default => true
    change_column :content_views, :display_labels,           :boolean, :default => true
    change_column :content_views, :allow_comments,           :boolean, :default => true
  end
end
