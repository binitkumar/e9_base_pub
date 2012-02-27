class AddSocialFeedsBooleanToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :social_feed_settings_completed, :boolean, :default => false
  end

  def self.down
    remove_column :content_views, :social_feed_settings_completed
  end
end
