class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|

      t.string  :name


      # Dev
      t.boolean :debug_mode

      #
      # Company Information
      #
      t.string  :site_name
      t.string  :copyright_start_year
      t.string  :domain_name
      t.text    :default_meta_description
      t.text    :default_meta_keywords
      t.text    :google_analytics_code
      t.text    :google_site_verification_code
      t.integer :avatar_size
      t.integer :content_icon_size
      t.integer :menu_icon_size
      t.integer :share_site_icon_size
      t.integer :layout_preview_width
      t.integer :layout_preview_height

      #
      # Page Settings
      #
      t.boolean :page_show_date
      t.boolean :page_show_social_bookmarks
      t.boolean :page_show_author_info
      t.boolean :page_show_labels
      t.boolean :page_allow_comments
      t.string  :page_submenu
      
      #
      # Linkable System Page Titles
      #

      t.string  :home_page_title
      t.string  :forums_page_title
      t.string  :blog_page_title
      t.string  :faqs_page_title
      t.string  :sign_in_page_title
      t.string  :sign_up_page_title
      t.string  :proile_page_title
      t.string  :edit_profile_page_title
      t.string  :blog_view
      t.string  :blog_submenu
      t.integer :blog_pagination_records
      t.integer :blog_teaser_body_length
      t.boolean :blog_show_date
      t.boolean :blog_show_social_bookmarks
      t.boolean :blog_show_author_info
      t.boolean :blog_show_labels
      t.boolean :blog_allow_comments

      #
      # Forum Settings
      #
      t.integer :forum_pagination_records

      #
      # FAQ Settings
      #
      t.boolean :faq_show_date
      t.boolean :faq_show_author_info

      #
      # Menu Settings
      #
      t.integer :menu_record_count

      #
      # Feed Settings
      #
      t.integer :feed_records
      t.integer :feed_summary_characters
      t.integer :feed_max_title_characters

      #
      # Misc. Public Settings
      #
      t.integer :records_per_page
      t.integer :search_records_per_page
      t.integer :home_records_per_page
      t.integer :admin_records_per_page
      t.integer :excerpt_display_chars
      t.integer :maximum_share_site_count

      #
      # Sales and Marketing Settings
      #
      t.string  :sales_email
      t.string  :contact_form_page_title
      t.text    :contact_form_page_text
      t.string  :contact_thanks_page_title
      t.text    :contact_thanks_page_text
      t.text    :add_sales_contact_intro

      #
      # Email Settings
      #
      t.string  :site_email_address
      t.text    :default_html_email
      t.text    :default_text_email

      #
      # Social Feed Settings
      #
      t.string  :twitter_login
      t.string  :twitter_password
      t.string  :facebook_login
      t.string  :facebook_password

      #
      # Admin Settings
      #
      t.boolean :display_custom_help

      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
