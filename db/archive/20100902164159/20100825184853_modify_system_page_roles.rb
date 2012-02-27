class ModifySystemPageRoles < ActiveRecord::Migration
  def self.up
    SystemPage.update_all ["role = ?", E9::Roles.top], ["type != ?", 'LinkableSystemPage']
    SystemPage.find_by_identifier(Page::Identifiers::SEARCH).update_attribute(:role, E9::Roles.bottom)
    SystemPage.find_by_identifier(Page::Identifiers::FOUR_O_FOUR).update_attribute(:role, E9::Roles.bottom)
  end

  def self.down
    SystemPage.update_all ["role = ?", 'guest']
  end
end
