class RemoveSocialFieldsFromContent < ActiveRecord::Migration
  def self.up
    remove_column :content_views, :post_to_facebook
    remove_column :content_views, :post_to_twitter
    remove_column :content_views, :twitter_comment
    remove_column :content_views, :facebook_comment
  end

  def self.down
    add_column :content_views, :facebook_comment, :string
    add_column :content_views, :twitter_comment, :string
    add_column :content_views, :post_to_twitter, :boolean
    add_column :content_views, :post_to_facebook, :boolean
  end
end
