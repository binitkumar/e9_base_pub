class E9Crm::SalesCampaignsController < E9Crm::CampaignSubclassController
  defaults :resource_class => SalesCampaign
  include E9::Controllers::Orderable

  helper 'e9_crm/campaigns'
end
