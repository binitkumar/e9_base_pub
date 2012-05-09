class DefaultOfferAndCampaignOffers < ActiveRecord::Migration
  def self.up
    add_column :campaigns,    :offer_id,    :integer
    add_column :renderables,  :is_default,  :boolean, :default => false
  end

  def self.down
    remove_column :renderables, :is_default
    remove_column :campaigns,   :offer_id
  end
end
