class ChangeMenuVconfigToLambda < ActiveRecord::Migration
  def self.up
    rename_column :menus, :v_config, :toggle_eval
  end

  def self.down
    rename_column :menus, :toggle_eval, :v_config
  end
end
