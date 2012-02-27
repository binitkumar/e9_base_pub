class QuestionsBecomeContent < ActiveRecord::Migration
  def self.up
    add_column :content_views, :faq_id, :integer
    add_column :content_views, :position, :integer
  end

  def self.down
    remove_column :content_views, :position
    remove_column :content_views, :faq_id
  end
end
