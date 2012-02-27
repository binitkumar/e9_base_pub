class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string     :query, :search_type
      t.string     :role
      t.references :user
      t.integer    :results_count, :search_count
      t.timestamps
    end
  end

  def self.down
    drop_table :searches
  end
end
