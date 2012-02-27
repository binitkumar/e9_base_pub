class AddEventFieldsToContentView < ActiveRecord::Migration
  def self.up
    add_column :content_views, :parent_id,                :integer
    add_column :content_views, :form_html,                :text

    add_column :content_views, :event_time,               :datetime
    add_column :content_views, :event_last_register_date, :date
    add_column :content_views, :event_capacity,           :integer,  :default => 0
    add_column :content_views, :event_max_guests,         :integer,  :default => 0
    add_column :content_views, :event_show_promo_code,    :boolean,  :default => true
    add_column :content_views, :event_is_free,            :boolean,  :default => true
  end

  def self.down
    remove_column :content_views, :event_is_free
    remove_column :content_views, :event_show_promo_code
    remove_column :content_views, :event_max_guests
    remove_column :content_views, :event_capacity
    remove_column :content_views, :event_last_register_date
    remove_column :content_views, :event_time

    remove_column :content_views, :form_html
    remove_column :content_views, :parent_id
  end
end
