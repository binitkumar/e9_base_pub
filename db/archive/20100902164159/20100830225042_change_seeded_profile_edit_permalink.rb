class ChangeSeededProfileEditPermalink < ActiveRecord::Migration
  def self.up
    ContentView.update_all ["permalink = ?", "profile/edit"], ["permalink = ?", "edit_profile"]
  end

  def self.down
    ContentView.update_all ["permalink = ?", "edit_profile"], ["permalink = ?", "profile/edit"]
  end
end
