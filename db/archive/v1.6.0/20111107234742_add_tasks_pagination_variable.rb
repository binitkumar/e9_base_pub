class AddTasksPaginationVariable < ActiveRecord::Migration
  def self.up
    add_column :settings, :notes_per_page, :integer
  end

  def self.down
    remove_column :settings, :notes_per_page
  end
end
