class SettingsMountChanges < ActiveRecord::Migration
  def self.up
    add_column :settings, :avatar, :string
    add_column :settings, :user_page_thumb, :string
    add_column :settings, :blog_post_thumb, :string
    add_column :settings, :question_thumb, :string

    remove_column :settings, :default_avatar
  end

  def self.down
    add_column :settings, :default_avatar

    remove_column :settings, :question_thumb
    remove_column :settings, :blog_post_thumb
    remove_column :settings, :user_page_thumb
    remove_column :settings, :avatar
  end
end
