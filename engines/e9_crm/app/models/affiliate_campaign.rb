# An affiliate campaign
#
# Carries an affiliate fee (and sales fee)
#
class AffiliateCampaign < SalesCampaign
  money_columns :affiliate_fee

  validates :affiliate, :presence => true

  # NOTE Affiliate campaigns calculate cost from deals, and each of its deals
  #      which are "Won" should carry the affiliate fee, and the sales fee
  def update_deal_costs(deal)
    super

    dated_costs.create({
      :deal    => deal,
      :contact => affiliate,
      :cost    => deal.won? ? affiliate_fee : 0,
      :label   => "#{self}: Affiliate Fee for #{deal.name}",
      :date    => deal.created_at.to_date
    })
  end
end
