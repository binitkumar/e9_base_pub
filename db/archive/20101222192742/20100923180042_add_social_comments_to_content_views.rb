class AddSocialCommentsToContentViews < ActiveRecord::Migration
  def self.up
    add_column :content_views, :post_to_facebook, :boolean
    add_column :content_views, :post_to_twitter, :boolean
    add_column :content_views, :twitter_comment, :text
    add_column :content_views, :facebook_comment, :text
  end

  def self.down
    remove_column :content_views, :facebook_comment
    remove_column :content_views, :twitter_comment
    remove_column :content_views, :post_to_twitter
    remove_column :content_views, :post_to_facebook
  end
end
