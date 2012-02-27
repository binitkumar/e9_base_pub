class AddEventSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :event_display_actions,       :boolean
    add_column :settings, :event_show_labels,           :boolean
    add_column :settings, :event_show_social_bookmarks, :boolean
    add_column :settings, :event_submenu,               :string
    add_column :settings, :event_thumb,                 :string
    add_column :settings, :facebook_event_template,     :text
    add_column :settings, :facebook_events_by_default,  :boolean, :default => true
    add_column :settings, :twitter_event_template,      :text
    add_column :settings, :twitter_events_by_default,   :boolean, :default => true

    add_column :settings, :m_gateway,       :string
    add_column :settings, :m_gateway_login, :string
    add_column :settings, :m_gateway_pass,  :string
    add_column :settings, :m_gateway_test,  :boolean, :default => true
  end

  def self.down
    remove_column :settings, :m_gateway_test
    remove_column :settings, :m_gateway_pass
    remove_column :settings, :m_gateway_login
    remove_column :settings, :m_gateway

    remove_column :settings, :twitter_events_by_default
    remove_column :settings, :twitter_event_template
    remove_column :settings, :facebook_events_by_default
    remove_column :settings, :facebook_event_template
    remove_column :settings, :event_thumb
    remove_column :settings, :event_submenu
    remove_column :settings, :event_show_social_bookmarks
    remove_column :settings, :event_show_labels
    remove_column :settings, :event_display_actions
  end
end
