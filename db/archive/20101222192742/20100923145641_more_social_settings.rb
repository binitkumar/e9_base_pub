class MoreSocialSettings < ActiveRecord::Migration
  def self.up
    remove_column :settings, :facebook_login
    remove_column :settings, :facebook_password
    remove_column :settings, :twitter_login
    remove_column :settings, :twitter_password

    add_column :settings, :facebook_company_page_url, :string
    add_column :settings, :facebook_company_page_id,  :string
    add_column :settings, :facebook_page_template, :text
    add_column :settings, :facebook_pages_by_default, :boolean, :default => true
    add_column :settings, :facebook_forum_template, :text
    add_column :settings, :facebook_forums_by_default, :boolean, :default => true

    add_column :settings, :twitter_page_template, :text
    add_column :settings, :twitter_pages_by_default, :boolean, :default => true
    add_column :settings, :twitter_forum_template, :text
    add_column :settings, :twitter_forums_by_default, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :twitter_forums_by_default
    remove_column :settings, :twitter_forum_template
    remove_column :settings, :twitter_pages_by_default
    remove_column :settings, :twitter_page_template

    remove_column :settings, :facebook_forums_by_default
    remove_column :settings, :facebook_forum_template
    remove_column :settings, :facebook_pages_by_default
    remove_column :settings, :facebook_page_template
    remove_column :settings, :facebook_company_page_id
    remove_column :settings, :facebook_company_page_url

    add_column :settings, :twitter_password, :string
    add_column :settings, :twitter_login, :string
    add_column :settings, :facebook_password, :string
    add_column :settings, :facebook_login, :string
  end

end
