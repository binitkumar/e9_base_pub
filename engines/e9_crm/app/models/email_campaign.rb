# An email campaign.
#
class EmailCampaign < Campaign

  # NOTE Email campaigns currently have no cost and their deals should not have
  #      individual costs
  def update_deal_costs(deal)
    super
  end
end
