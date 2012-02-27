module E9Crm::VisitsHelper
  def visits_campaign_select_options(campaign)
    @_campaigns ||= begin
      campaigns = Campaign.order('name ASC').all

      if nocampaign = campaigns.detect {|n| n.is_a?(NoCampaign) }
        campaigns.unshift campaigns.delete(nocampaign)
      end

      campaigns
    end

    options = @_campaigns.map {|c| [c.to_s, campaign_visits_path(c)] }

    options_for_select(options, campaign && campaign_visits_path(campaign))
  end
end
