class CreateHardLinks < ActiveRecord::Migration
  def self.up
    create_table :hard_links do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :hard_links
  end
end
