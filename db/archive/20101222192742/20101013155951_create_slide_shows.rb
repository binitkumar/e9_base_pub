class CreateSlideShows < ActiveRecord::Migration
  def self.up
    create_table :slide_shows do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :slide_shows
  end
end
