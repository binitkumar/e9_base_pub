class CreateRenderables < ActiveRecord::Migration
  def self.up
    create_table :renderables do |t|
      t.string :name, :type
      t.string :role
      t.timestamps
    end
  end

  def self.down
    drop_table :renderables
  end
end
