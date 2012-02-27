class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.string :name, :identifier
      #t.references :linkable, :polymorphic => true
      t.references :link
      t.references :parent, :page
      t.integer :lft, :rgt, :depth
      t.boolean :master,     :default => false
      t.boolean :new_window, :default => false
      t.boolean :external,   :default => false
      t.boolean :system,     :default => false
      t.boolean :role_strict, :default => false

      # soft link
      t.boolean :delegate_title_to_link, :default => true

      # hard link
      t.string  :href
    
      # hard link used to distinguish between "add link" and "add page", not editable
      t.boolean :hard_link,  :default => false

      t.string :v_config
      t.string :off_icon, :hover_icon, :selected_icon
      t.string :role
    end
  end

  def self.down
    drop_table :menus
  end
end
