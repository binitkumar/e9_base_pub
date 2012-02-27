class SocialFeedSettingsChanges < ActiveRecord::Migration
  def self.up
    add_column :settings, :facebook_slides_by_default, :boolean
    add_column :settings, :facebook_blog_posts_by_default, :boolean
    add_column :settings, :facebook_slideshows_by_default, :boolean

    add_column :settings, :twitter_slides_by_default, :boolean
    add_column :settings, :twitter_blog_posts_by_default, :boolean
    add_column :settings, :twitter_slideshows_by_default, :boolean
  end

  def self.down
    remove_column :settings, :twitter_slideshows_by_default
    remove_column :settings, :twitter_blog_posts_by_default
    remove_column :settings, :twitter_slides_by_default

    remove_column :settings, :facebook_slideshows_by_default
    remove_column :settings, :facebook_blog_posts_by_default
    remove_column :settings, :facebook_slides_by_default
  end
end
