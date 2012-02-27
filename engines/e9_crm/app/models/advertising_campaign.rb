# An ad driven campaign.
#
# Unique from other campaigns in that their cost is derived from associated
# DatedCost records.
#
class AdvertisingCampaign < Campaign

  accepts_nested_attributes_for :dated_costs

  # NOTE Advertising campaign costs have nothing to do with won deals, and 
  #      deals for an ad campaign should not have individual costs
  def update_deal_costs(deal)
    super
  end
end
