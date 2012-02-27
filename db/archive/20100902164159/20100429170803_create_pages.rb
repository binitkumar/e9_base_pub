class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      # for STI
      t.string  :type 

      # user
      t.string   :permalink
      t.boolean  :published,                :default => false

      # system
      t.boolean  :master,                   :default => false 
      t.string   :identifier
      t.boolean  :hidden,                   :default => false

      # for blog post
      t.references :blog

      # for topic
      t.references :forum
      t.integer :comments_count,            :default => 0

      # common
      t.references :user
      t.string   :title
      t.string   :role
      t.text     :body
      t.text     :text_version
      t.text     :meta_description

      t.boolean  :display_social_bookmarks, :default => true
      t.boolean  :display_date,             :default => true
      t.boolean  :display_author_info,      :default => true
      t.boolean  :display_labels,           :default => true
      t.boolean  :allow_comments,           :default => true

      t.boolean  :previously_published,     :default => false

      t.integer  :comments_count,           :default => 0

      t.datetime :published_at,
                 :updated_by
      t.timestamps
    end

    add_index :pages, :permalink, :unique => true
  end

  def self.down
    drop_table :pages
  end
end
