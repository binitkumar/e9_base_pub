class RemoveBlogs < ActiveRecord::Migration
  def self.up
    drop_table :blogs rescue nil
  end

  def self.down
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
      t.integer  "position"
    end

    add_index "blogs", ["slug"], :name => "index_blogs_on_slug", :unique => true
  end
end
