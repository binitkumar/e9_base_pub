class RemoveOldOffersTable < ActiveRecord::Migration
  def self.up
    remove_index :offers, :column => :tracking_cookie_id
    remove_index :offers, :column => :campaign_id
    remove_index :offers, :column => :offer_id

    drop_table :offers

    remove_index :offer_responses, :column => :contact_id
    remove_index :offer_responses, :column => :campaign_id
    remove_index :offer_responses, :column => :offer_id

    drop_table :offer_responses
  end

  def self.down
    # There's no reason to do this, these tables are long gone
  end
end
