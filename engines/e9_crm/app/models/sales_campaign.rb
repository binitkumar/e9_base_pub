# An sales campaign
#
# Carries an affiliate fee
#
class SalesCampaign < Campaign
  money_columns :sales_fee

  validates :sales_person, :presence => { :if => lambda {|x| x.type == 'SalesCampaign' } }

  # NOTE Sales campaigns calculate cost from deals, and each Won deal associated
  #      with a sales campaign should carry the campaign's sales fee
  def update_deal_costs(deal)
    super

    dated_costs.create({
      :deal    => deal,
      :contact => sales_person,
      :cost    => deal.won? ? sales_fee : 0,
      :label   => "#{self}: Sales Fee for #{deal.name}",
      :date    => deal.created_at.to_date
    })
  end
end
