class CreateE9Attributes < ActiveRecord::Migration
  def self.up
    create_table :record_attributes, :force => true do |t|
      t.string :type
      t.references :record, :polymorphic => true
      t.text :value, :options, :limit => 3.kilobytes
    end

    create_table :menu_options, :force => true do |t|
      t.integer :position
      t.string  :key
      t.string  :value
    end
  end

  def self.down
    drop_table :menu_options
    drop_table :record_attributes
  end
end
