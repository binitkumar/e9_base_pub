Rails.application.routes.draw do
  crm_path = 'admin/crm'

  get '/autocomplete/contacts'        => E9Crm::Rack::ContactAutoCompleter
  get '/autocomplete/companies'       => E9Crm::Rack::CompanyAutoCompleter
  get '/autocomplete/deals'           => E9Crm::Rack::DealAutoCompleter
  get '/autocomplete/email_campaigns' => E9Crm::Rack::EmailCampaignAutoCompleter
  get '/users/email_test.json'        => E9Crm::Rack::EmailAvailabilityChecker

  scope :module => :e9_crm do

    # specific_offer and default_offer actually return a new lead associated
    # with the found offer and the <form> used to persist it.
    #
    # The default_offer is determined by the currently tracked campaign, 
    # or the default offer specified in the admin.
    #
    # specific_offer is a just a prettier shortcut to /offers/XX/new to match
    # the shorter '/offer'
    #
    get '/offer', :as => :default_offer, :to => 'leads#campaign_or_default_offer_lead_redirect'
    get '/offer/:id', :to => redirect('/offers/%{id}/new')

    resources :offers, :as => :public_offer, :only => :show do
      resources :leads, :as => :deals, :only => [:new, :create], :path => ''
    end
  end

  scope :module => :e9_crm, :path => 'admin' do
    resources :notes, :path => 'dashboard', :except => :show

    resources :tasks, :except => [:index, :show] do
      member { post :toggle }
    end
  end

  scope :path => crm_path, :module => :e9_crm do
    # NOTE this should be handled by base, and is here because base doesn't have a sensible
    # user api, which crm needs to check for email uniqueness errors
    resources :users, :only => :new

    resources :companies, :except => :show
    resources :contacts do
      resources :dated_costs, :path => 'payments'

      collection do 
        get :templates
        get :payments, :to => 'dated_costs#payments'
      end

      member do
        post   :upload_avatar
        delete :reset_avatar
      end
    end

    resources :page_views, :path => 'activity', :only => :index

    resources :deals do
      member do
        get :edit_costs
        put :update_costs
      end
    end

    resources :dated_costs, :path => 'costs', :only => [:destroy] do
      collection do
        post :bulk_create
      end
    end

    get 'advertising_costs', :to => 'dated_costs', :as => :advertising_costs

    resources :campaigns, :only  => [:index, :destroy, :new] do
      resources :visits, :path => 'activity', :only => :index
    end
    scope :path => :campaigns do

      resources :campaign_groups, :path => 'groups', :except => [:show]

      resources :sales_campaigns,       :path => 'sales',       :except => [:show, :index]
      resources :affiliate_campaigns,   :path => 'affiliate',   :except => [:show, :index]
      resources :email_campaigns,       :path => 'email',       :except => [:show, :index]

      resources :advertising_campaigns, :path => 'advertising', :except => [:show, :index] do
        resources :dated_costs, :path => 'costs'
      end

      %w( advertising affiliate email sales ).each do |path|
        get "/#{path}", :to => redirect("/#{crm_path}/campaigns?type=#{path}")
      end
    end

    resources :offers, :except => :show

    # leads are simply a scoped view of deals (only index)
    get 'leads',            :as => :leads,          :to => 'deals#leads'
    get 'marketing_report', :as => :marketing_report, :to => 'campaigns#reports'

    get  '/merge_contacts/:contact_a_id/and/:contact_b_id', :as => :new_contact_merge, :to => 'contact_merges#new'
    post '/merge_contacts', :as => :contact_merges, :to => 'contact_merges#create'

    # redirect shows to edits
    %w(
      campaigns/advertising
      campaigns/affiliate
      campaigns/email
      campaigns/sales
      campaigns/groups
      deals
      offers
    ).each do |path|
      get "/#{path}/:id", :to => redirect("/#{crm_path}/#{path}/%{id}/edit"), :constraints => { :id => /\d+/ }
    end

  end
end
