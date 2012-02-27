class AddRevokablePage < ActiveRecord::Migration
  def self.up
    unless ContentView.find_by_identifier(Page::Identifiers::REVOKE)
      Layout.for(UserPage).
        prototype!(LinkableSystemPage, {
          :title => "Manage Your Account", 
          :author => User.first, 
          :identifier => Page::Identifiers::REVOKE,       
          :permalink => 'revoke',      
          :editable_content => false
        })

    end
  end

  def self.down
    ContentView.destroy_all ["identifier = ?", Page::Identifiers::REVOKE]
  end
end
