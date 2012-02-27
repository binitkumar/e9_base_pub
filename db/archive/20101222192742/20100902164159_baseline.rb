class Baseline < ActiveRecord::Migration
  def self.up
    create_table "blogs", :force => true do |t|
      t.string   "title"
      t.string   "role"
      t.string   "slug"
      t.text     "description"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "master",           :default => false
      t.text     "meta_description"
      t.text     "meta_keywords"
    end

    add_index "blogs", ["slug"], :name => "index_blogs_on_slug", :unique => true

    create_table "categories", :force => true do |t|
      t.string   "title"
      t.string   "type"
      t.string   "role"
      t.integer  "user_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "comments", :force => true do |t|
      t.integer  "commentable_id"
      t.string   "commentable_type"
      t.integer  "user_id"
      t.string   "title"
      t.text     "body"
      t.boolean  "deleted",          :default => false
      t.integer  "deleter_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

    create_table "content_updates", :force => true do |t|
      t.integer  "content_id"
      t.string   "content_type"
      t.string   "sub_content_type"
      t.string   "role"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "content_views", :force => true do |t|
      t.string   "type"
      t.string   "permalink"
      t.boolean  "published",                :default => false
      t.boolean  "master",                   :default => false
      t.string   "identifier"
      t.boolean  "hidden",                   :default => false
      t.integer  "blog_id"
      t.integer  "forum_id"
      t.integer  "comments_count",           :default => 0
      t.integer  "user_id"
      t.string   "title"
      t.string   "role"
      t.text     "body"
      t.text     "text_version"
      t.text     "meta_description"
      t.boolean  "display_social_bookmarks"
      t.boolean  "display_date"
      t.boolean  "display_author_info"
      t.boolean  "display_labels"
      t.boolean  "allow_comments"
      t.boolean  "previously_published",     :default => false
      t.datetime "published_at"
      t.datetime "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "layout_id"
      t.boolean  "editable_content",         :default => true
      t.string   "author_string"
    end

    add_index "content_views", ["permalink"], :name => "index_pages_on_permalink", :unique => true

    create_table "emails", :force => true do |t|
      t.integer  "mailing_list_id"
      t.string   "name"
      t.string   "type"
      t.string   "subject"
      t.string   "status",          :default => "p"
      t.string   "identifier"
      t.string   "to_email"
      t.string   "from_email"
      t.string   "reply_email"
      t.text     "html_body"
      t.text     "text_body"
      t.date     "delivery_date"
      t.boolean  "deletable",       :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sent_count"
    end

    create_table "favorites", :force => true do |t|
      t.integer  "user_id"
      t.integer  "favoritable_id"
      t.string   "favoritable_type"
      t.string   "sub_favoritable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "flags", :force => true do |t|
      t.integer  "flaggable_id"
      t.string   "flaggable_type"
      t.integer  "user_id"
      t.string   "reason"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "flags", ["user_id"], :name => "index_flags_on_user_id"

    create_table "friend_emails", :force => true do |t|
      t.integer  "user_id"
      t.integer  "link_id"
      t.string   "recipient_email"
      t.string   "sender_email"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "hard_links", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "hits", :force => true do |t|
      t.integer  "hittable_id"
      t.string   "hittable_type"
      t.date     "created_date"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "images", :force => true do |t|
      t.string   "file"
      t.integer  "height"
      t.integer  "width"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "layouts", :force => true do |t|
      t.string   "identifier"
      t.string   "name"
      t.string   "template"
      t.string   "preview"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "layout_preview"
      t.boolean  "system",         :default => false
      t.integer  "parent_id"
      t.string   "role"
    end

    create_table "layouts_region_types", :id => false, :force => true do |t|
      t.integer "layout_id"
      t.integer "region_type_id"
    end

    create_table "linkable_system_pages", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "links", :force => true do |t|
      t.integer  "linkable_id"
      t.string   "linkable_type"
      t.string   "sub_linkable_type"
      t.string   "role"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "mailing_lists", :force => true do |t|
      t.string   "name"
      t.string   "identifier"
      t.string   "role"
      t.string   "description"
      t.integer  "subscriptions_count", :default => 0
      t.boolean  "system",              :default => false
      t.boolean  "newsletter",          :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "menus", :force => true do |t|
      t.string   "name"
      t.string   "identifier"
      t.integer  "link_id"
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "depth"
      t.boolean  "new_window",             :default => false
      t.boolean  "external",               :default => false
      t.boolean  "system",                 :default => false
      t.boolean  "logged_out_only",        :default => false
      t.boolean  "delegate_title_to_link", :default => true
      t.string   "href"
      t.string   "toggle_eval"
      t.string   "icon"
      t.string   "role"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "path_pattern"
      t.string   "type"
      t.boolean  "editable",               :default => true
    end

    create_table "nodes", :force => true do |t|
      t.integer  "renderable_id"
      t.integer  "region_id"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "preferences", :force => true do |t|
      t.string   "name",       :null => false
      t.integer  "owner_id",   :null => false
      t.string   "owner_type", :null => false
      t.integer  "group_id"
      t.string   "group_type"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "preferences", ["owner_id", "owner_type", "name", "group_id", "group_type"], :name => "index_preferences_on_owner_and_name_and_preference", :unique => true

    create_table "questions", :force => true do |t|
      t.integer  "faq_id"
      t.integer  "user_id"
      t.integer  "position"
      t.string   "title"
      t.string   "author_text"
      t.datetime "published_at"
      t.text     "answer"
      t.text     "text_version"
      t.boolean  "display_author_info", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "region_types", :force => true do |t|
      t.string "name"
      t.string "domid"
      t.string "role"
      t.string "expand_menus", :default => "always"
    end

    create_table "region_types_renderables", :id => false, :force => true do |t|
      t.integer "region_type_id"
      t.integer "renderable_id"
    end

    create_table "regions", :force => true do |t|
      t.integer  "view_id"
      t.string   "view_type"
      t.integer  "region_type_id"
      t.string   "name"
      t.string   "domid"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "renderables", :force => true do |t|
      t.string   "name"
      t.string   "type"
      t.string   "role"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "template"
      t.text     "revert_template"
      t.text     "file"
      t.integer  "menu_id"
      t.boolean  "system",          :default => false
      t.string   "identifier"
    end

    create_table "searches", :force => true do |t|
      t.string   "query"
      t.string   "search_type"
      t.string   "role"
      t.integer  "user_id"
      t.integer  "results_count"
      t.integer  "search_count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "settings", :force => true do |t|
      t.string   "name"
      t.boolean  "debug_mode"
      t.string   "site_name"
      t.string   "copyright_start_year"
      t.string   "domain_name"
      t.text     "default_meta_description"
      t.text     "default_meta_keywords"
      t.text     "google_analytics_code"
      t.text     "google_site_verification_code"
      t.integer  "avatar_size"
      t.integer  "content_icon_size"
      t.integer  "menu_icon_size"
      t.integer  "share_site_icon_size"
      t.integer  "layout_preview_width"
      t.integer  "layout_preview_height"
      t.boolean  "page_show_date"
      t.boolean  "page_show_social_bookmarks"
      t.boolean  "page_show_author_info"
      t.boolean  "page_show_labels"
      t.boolean  "page_allow_comments"
      t.string   "page_submenu"
      t.string   "home_page_title"
      t.string   "forums_page_title"
      t.string   "blog_page_title"
      t.string   "faqs_page_title"
      t.string   "sign_in_page_title"
      t.string   "sign_up_page_title"
      t.string   "proile_page_title"
      t.string   "edit_profile_page_title"
      t.string   "blog_view"
      t.string   "blog_submenu"
      t.integer  "blog_pagination_records"
      t.integer  "blog_teaser_body_length"
      t.boolean  "blog_show_date"
      t.boolean  "blog_show_social_bookmarks"
      t.boolean  "blog_show_author_info"
      t.boolean  "blog_show_labels"
      t.boolean  "blog_allow_comments"
      t.integer  "forum_pagination_records"
      t.boolean  "faq_show_date"
      t.boolean  "faq_show_author_info"
      t.integer  "menu_record_count"
      t.integer  "feed_records"
      t.integer  "feed_summary_characters"
      t.integer  "feed_max_title_characters"
      t.integer  "records_per_page"
      t.integer  "search_records_per_page"
      t.integer  "home_records_per_page"
      t.integer  "admin_records_per_page"
      t.integer  "excerpt_display_chars"
      t.integer  "maximum_share_site_count"
      t.string   "sales_email"
      t.string   "contact_form_page_title"
      t.text     "contact_form_page_text"
      t.string   "contact_thanks_page_title"
      t.text     "contact_thanks_page_text"
      t.text     "add_sales_contact_intro"
      t.string   "site_email_address"
      t.text     "default_html_email"
      t.text     "default_text_email"
      t.string   "twitter_login"
      t.string   "twitter_password"
      t.string   "facebook_login"
      t.string   "facebook_password"
      t.boolean  "display_custom_help"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "share_sites", :force => true do |t|
      t.string   "name"
      t.text     "url"
      t.integer  "position"
      t.boolean  "enabled",    :default => true
      t.integer  "icon_index"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "site_configurations", :force => true do |t|
      t.string   "name"
      t.string   "site_name"
      t.string   "copyright_start_year"
      t.string   "site_email_address"
      t.string   "blog_name"
      t.string   "internal_blog_name"
      t.string   "forum_name"
      t.string   "default_avatar"
      t.string   "favicon"
      t.string   "twitter_login"
      t.string   "twitter_password"
      t.string   "facebook_login"
      t.string   "facebook_password"
      t.integer  "admin_records_per_page"
      t.integer  "records_per_page"
      t.text     "google_analytics_code"
      t.text     "email_a_friend_footer_text"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "default_content_icon"
    end

    create_table "soft_links", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "subscriptions", :force => true do |t|
      t.integer  "user_id"
      t.integer  "mailing_list_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "unsubscribe_token"
    end

    add_index "subscriptions", ["unsubscribe_token"], :name => "index_subscriptions_on_unsubscribe_token", :unique => true

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "sub_taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

    create_table "topics", :force => true do |t|
      t.string   "title"
      t.integer  "forum_id"
      t.integer  "user_id"
      t.integer  "comments_count", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "users", :force => true do |t|
      t.string   "email"
      t.string   "encrypted_password",              :limit => 128, :default => "",    :null => false
      t.string   "password_salt",                                  :default => "",    :null => false
      t.string   "reset_password_token"
      t.string   "remember_token"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                                  :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "username"
      t.string   "role"
      t.boolean  "auto_favorite",                                  :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "avatar"
      t.string   "subscriptions_token"
      t.boolean  "content_notifications",                          :default => true
      t.boolean  "comment_and_topic_notifications",                :default => true
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  end

  def self.down
    remove_index "users", :name => "index_users_on_reset_password_token"
    remove_index "users", :name => "index_users_on_email"

    drop_table "users"

    drop_table "topics"

    drop_table "tags"

    remove_index "taggings", :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
    remove_index "taggings", :name => "index_taggings_on_tag_id"

    drop_table "taggings"

    remove_index "subscriptions", :name => "index_subscriptions_on_unsubscribe_token"

    drop_table "subscriptions"

    drop_table "soft_links"

    drop_table "site_configurations"

    drop_table "share_sites"

    drop_table "settings"

    drop_table "searches"

    drop_table "renderables"

    drop_table "regions"

    drop_table "region_types_renderables"

    drop_table "region_types"

    drop_table "questions"

    remove_index "preferences", :name => "index_preferences_on_owner_and_name_and_preference"

    drop_table "preferences"

    drop_table "nodes"

    drop_table "menus"

    drop_table "mailing_lists"

    drop_table "links"

    drop_table "linkable_system_pages"

    drop_table "layouts_region_types"

    drop_table "layouts"

    drop_table "images"

    drop_table "hits"

    drop_table "hard_links"

    drop_table "friend_emails"

    remove_index "flags", :name => "index_flags_on_user_id"

    drop_table "flags"

    drop_table "favorites"

    drop_table "emails"

    remove_index "content_views", :name => "index_pages_on_permalink"

    drop_table "content_views"

    drop_table "content_updates"

    remove_index "comments", :name => "index_comments_on_user_id"

    drop_table "comments"

    drop_table "categories"

    remove_index "blogs", :name => "index_blogs_on_slug"

    drop_table "blogs"
  end
end
