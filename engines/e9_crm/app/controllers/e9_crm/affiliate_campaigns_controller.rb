class E9Crm::AffiliateCampaignsController < E9Crm::CampaignSubclassController
  defaults :resource_class => AffiliateCampaign
  include E9::Controllers::Orderable

  helper 'e9_crm/campaigns'
end
