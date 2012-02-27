class AddSlideSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :slide_show_social_bookmarks, :boolean
    add_column :settings, :slide_show_date, :boolean
    add_column :settings, :slide_show_author_info, :boolean
    add_column :settings, :slide_show_labels, :boolean
    add_column :settings, :slide_allow_comments, :boolean

    add_column :settings, :slide_embeddable_width,  :integer
    add_column :settings, :slide_embeddable_height, :integer
  end

  def self.down
    remove_column :settings, :slide_embeddable_height
    remove_column :settings, :slide_embeddable_width

    remove_column :settings, :slide_allow_comments
    remove_column :settings, :slide_show_labels
    remove_column :settings, :slide_show_author_info
    remove_column :settings, :slide_show_date
    remove_column :settings, :slide_show_social_bookmarks
  end
end
