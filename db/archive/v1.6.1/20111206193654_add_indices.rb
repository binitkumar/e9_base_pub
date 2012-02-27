class AddIndices < ActiveRecord::Migration
  def self.up
    # TOPICS, QUESTIONS, CONTENT_UPDATES no longer exist
    
    add_index :attachments, [:owner_id, :owner_type]
    add_index :attachments, :image_spec_id

    # NOTE campaign_group_id already indexed
    add_index :campaigns, :affiliate_id
    add_index :campaigns, :sales_person_id

    add_index :categories, :user_id
    add_index :categories, :layout_id

    add_index :content_views, :user_id
    add_index :content_views, :blog_id
    add_index :content_views, :forum_id
    add_index :content_views, :layout_id

    add_index :dated_costs, [:costable_id, :costable_type]
    add_index :dated_costs, :deal_id
    add_index :dated_costs, :contact_id

    add_index :email_deliveries, :campaign_id
    add_index :email_deliveries, :email_id

    add_index :emails, :mailing_list_id

    add_index :event_registrations, :event_id
    add_index :event_registrations, :user_id
    add_index :event_registrations, :event_transaction_id

    add_index :event_transactions, :event_id

    add_index :favorites, :user_id
    add_index :favorites, [:favoritable_id, :favoritable_type]

    # note user_id already exists
    add_index :flags, [:flaggable_id, :flaggable_type]

    add_index :hits, [:hittable_id, :hittable_type]

    add_index :layouts_region_types, :layout_id
    add_index :layouts_region_types, :region_type_id

    add_index :links, [:linkable_id, :linkable_type]

    add_index :menus, :link_id
    add_index :menus, :parent_id

    add_index :nodes, :renderable_id
    add_index :nodes, :region_id

    add_index :note_assignments, :note_id
    add_index :note_assignments, [:assigned_id, :assigned_type]

    add_index :notes, :contact_id

    add_index :offers, :offer_id
    add_index :offers, :campaign_id
    add_index :offers, :tracking_cookie_id

    add_index :poll_answers, :poll_id

    add_index :record_attributes, [:record_id, :record_type]

    add_index :region_types_renderables, :region_type_id
    add_index :region_types_renderables, :renderable_id

    add_index :regions, :region_type_id
    add_index :regions, [:view_id, :view_type]

    add_index :renderables, :associated_id
    add_index :renderables, [:owner_id, :owner_type]
    add_index :renderables, :template_id

    add_index :searches, :user_id

    add_index :slideshow_assignments, :slide_id
    add_index :slideshow_assignments, :slideshow_id

    add_index :subscriptions, :user_id
    add_index :subscriptions, :mailing_list_id

    add_index :users, :contact_id
  end

  def self.down
    remove_index :users, :column => :contact_id

    remove_index :subscriptions, :column => :mailing_list_id
    remove_index :subscriptions, :column => :user_id

    remove_index :slideshow_assignments, :column => :slideshow_id
    remove_index :slideshow_assignments, :column => :slide_id

    remove_index :searches, :column => :user_id

    remove_index :renderables, :column => :template_id
    remove_index :renderables, :column => [:owner_id, :owner_type]
    remove_index :renderables, :column => :associated_id

    remove_index :regions, :column => [:view_id, :view_type]
    remove_index :regions, :column => :region_type_id

    remove_index :region_types_renderables, :column => :renderable_id
    remove_index :region_types_renderables, :column => :region_type_id

    remove_index :record_attributes, :column => [:record_id, :record_type]

    remove_index :poll_answers, :column => :poll_id

    remove_index :offers, :column => :tracking_cookie_id
    remove_index :offers, :column => :campaign_id
    remove_index :offers, :column => :offer_id

    remove_index :notes, :column => :contact_id

    remove_index :note_assignments, :column => [:assigned_id, :assigned_type]
    remove_index :note_assignments, :column => :note_id

    remove_index :nodes, :column => :region_id
    remove_index :nodes, :column => :renderable_id

    remove_index :menus, :column => :parent_id
    remove_index :menus, :column => :link_id

    remove_index :links, :column => [:linkable_id, :linkable_type]

    remove_index :layouts_region_types, :column => :region_type_id
    remove_index :layouts_region_types, :column => :layout_id

    remove_index :hits, :column => [:hittable_id, :hittable_type]

    remove_index :flags, :column => [:flaggable_id, :flaggable_type]
    # note user_id already exists

    remove_index :favorites, :column => [:favoritable_id, :favoritable_type]
    remove_index :favorites, :column => :user_id

    remove_index :event_transactions, :column => :event_id

    remove_index :event_registrations, :column => :event_transaction_id
    remove_index :event_registrations, :column => :user_id
    remove_index :event_registrations, :column => :event_id

    remove_index :emails, :column => :mailing_list_id

    remove_index :email_deliveries, :column => :email_id
    remove_index :email_deliveries, :column => :campaign_id

    remove_index :dated_costs, :column => :contact_id
    remove_index :dated_costs, :column => :deal_id
    remove_index :dated_costs, :column => [:costable_id, :costable_type]

    remove_index :content_views, :column => :layout_id
    remove_index :content_views, :column => :forum_id
    remove_index :content_views, :column => :blog_id
    remove_index :content_views, :column => :user_id

    remove_index :categories, :column => :layout_id
    remove_index :categories, :column => :user_id

    remove_index :campaigns, :column => :sales_person_id
    remove_index :campaigns, :column => :affiliate_id
    # NOTE campaign_group_id already indexed

    remove_index :attachments, :column => :image_spec_id
    remove_index :attachments, :column => [:owner_id, :owner_type]
    
    # TOPICS, QUESTIONS, CONTENT_UPDATES no longer exist
  end
end
