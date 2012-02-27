class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.references :faq, :user
      t.integer :position
      t.string :title, :author_text
      t.datetime :published_at
      t.text :answer, :text_version
      t.boolean :display_author_info, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
