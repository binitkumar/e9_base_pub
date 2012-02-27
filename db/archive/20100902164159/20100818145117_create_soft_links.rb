class CreateSoftLinks < ActiveRecord::Migration
  def self.up
    create_table :soft_links do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :soft_links
  end
end
