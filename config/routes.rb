Rails.application.routes.draw do
  named_routes = Rails.application.routes.named_routes

  # init devise and specify override controllers
  devise_for :users, :controllers => { :passwords => 'passwords', :sessions => 'sessions', :registrations => 'registrations' }

  # this remaps /users/login etc to /login etc.
  as :user do
    get "/sign_in",  :to => "sessions#new", :as => :new_user_session
    post "/sign_in", :to => "sessions#create", :as => :user_session
    get "/sign_up", :to => "registrations#new", :as => :new_user_registration
    post "/sign_up", :to => "registrations#create", :as => :user_registration
    get "/sign_out", :to => "sessions#destroy", :as => :destroy_user_session
    get "/revoke", :to => "revocations#edit", :as => :confirm_user_revocation
    put "/revoke", :to => "revocations#update", :as => :user_revocation
  end

  # in app/metal
  get '/autocomplete/search' => SearchAutoCompleter

  #if Rails.env.production?
    get '/sitemap', :to => 'site_map#index', :defaults => { :format => 'xml' }
  #end

  # 'y' and 'm' added to date search index routes to disambiguate from show routes (e.g. blogs_path has a minimum of 3 segments and cannot be mistaken as /blog/:id)
  get '/blog(/y/:year(/m/:month))',                :as => :blogs,          :to => 'blog_posts#index',      :constraints => { :month => /\d{1,2}/, :year => /\d{4}/ }
  get '/blogs/:blog_id(/y/:year(/m/:month))',      :as => :blog,           :to => 'blog_posts#index',      :constraints => { :month => /\d{1,2}/, :year => /\d{4}/ }
  get '/blogs/:blog_id/:id',                       :as => :blog_blog_post, :to => 'blog_posts#show',       :constraints => PermalinkExistsConstraint.new(true)

  get '/admin/social_feeds', :as => :admin_social_feeds, :to => 'admin/social_feeds#index'

  scope :controller => :tasks do
    get '/tasks/deliver_scheduled_email'
  end

  resources :twitter_statuses
  resources :facebook_posts

  # for wysiwg
  resources :templates,     :only => [:index, :show]

  # for e9_attributes
  get 'attrs/users', :as => :user_templates, :to => 'profiles#templates', :format => :js

  resources :searches,      :only => [:show, :index], :path => 'search', :controller => :search
  resources :friend_emails, :only => [:new, :create]
  resources :subscriptions, :only => [:show, :update] 

  get '/faqs(/:role)(#faq_:faq_id)',            :as => :faq,       :to => 'faqs#index'
  get '/faqs(/:role)(#question_:question_id)',  :as => :question,  :to => 'faqs#index'

  resources :forums, :only => :index do
    resources :topics, :only => [:index, :new]
  end
  get 'forums/:forum_id', :as => :forum, :to => 'topics#index'

  resources :topics do
    resources :comments, :only => [:create, :destroy, :index]
  end

  resources :pages, :only => :show do
    resources :comments, :only => [:create, :destroy, :index]
  end

  resources :events, :only => [:show, :index] do
    resources :event_transactions, :path => 'registrations', :only => [:create, :new, :show]
    resources :event_registrations, :path => 'attendees', :only => [:new]

    collection do
      get 'type/:event_type', :to => 'events#index', :as => :typed
      get 'templates',        :to => 'events#templates', :format => :js
    end
  end

  # TODO rewrite content_views resourceful route to spec only rss
  get '/content_views', :as => :content_views, :to => 'content_views#index', :defaults => { :format => 'rss' }
  resources :content_views, :only => [] do
    resources :comments, :only => [:create, :destroy, :index]
  end

  resources :slides, :only => [:index, :show]

  # TODO  slide polymorphic_args don't use this route.  Is problematic?  The main issue is that slide_url(:foo => 'bar') appends query params after the anchor 
  # get "/slides#:id", :as => :slide, :to => 'slides#index'
  # get '/slides/:id', :to => redirect('/slides#%{id}')

  get "/slideshows",               :as => :slideshows, :to => 'slideshows#index'
  get "/slideshows/:slideshow_id", :as => :slideshow, :to => 'slides#index'

  resources :comments, :only => [:index, :destroy] do
    resource :flag, :only => [:create, :destroy]
  end

  resources :image_mounts do
    collection do
      post :temp
      post :update_order
    end
    member do
      delete :reset
    end
  end

  resources :banners, :only => :show do
    resources :image_mounts do
      collection do
        post :update_order
      end
    end
  end

  resources :images, :path => 'image_uploads' do
    collection do
      get :select
    end
  end

  resources :attachments, :path => 'file_uploads'

  resource :profile, :only => [:edit, :update, :show] do
    member do
      delete :unsave_all
      get    :change_password
    end
    resources :favorites, :only => [:index, :create, :destroy]
  end

  unless named_routes[:users]
    resources :users, :path => :profiles, :only => [:show, :index]
  end

  namespace :admin do
    # /admin/users/comments is recognized as admin/users/:id
    # if :show is enabled for users it will need a constraint, e.g. /admin/users/\d+
    # to allow /admin/users/comments to still route properly
    resources :users do
      resources :comments, :only => :index do
        collection do
          get :flagged
          put :delete_all
        end
      end
    end

    resources :comments, :only => :index do
      resource :flag, :only => [:create, :destroy]
      collection do
        get :flagged
      end
    end

    resources :events, :except => :show do
      resources :event_registrations, :path => 'attendees', :only => [:update, :index, :destroy] do
        member do
          get :transfer
          get :edit_voucher
        end
        collection do
          put :mark_attended
        end
      end

      collection do
        get :report
      end

      member do
        put :change_layout
        get :layouts
        get :social_form
        put :social_update
        put :publish
        put :unpublish
      end
    end

    resources :user_pages, :except => :show, :path => 'pages' do
      member do
        put :change_layout
        get :layouts
        get :social_form
        put :social_update
        put :publish
        put :unpublish
      end
    end

    resources :slides, :except => :show do
      member do
        put :change_layout
        get :layouts
        get :social_form
        put :social_update
        put :publish
        put :unpublish
      end
    end

    resources :blog_posts, :except => :show do
      member do
        get :social_form
        put :social_update
        put :publish
        put :unpublish
      end
    end
    resources :system_pages, :except => :show

    resources :slideshows, :except => :show do
      member do
        get :social_form
        put :social_update
      end
      collection do
        post :update_order
      end

      resources :slides, :except => :show do
        member do
          delete :remove
          put :publish
          put :unpublish
        end
        collection do
          put  :add
          post :update_order
        end
      end
    end

    # menus#show redirects to submenus
    resources :menus, :except => :show do
      resources :submenus, :only => :index do
        collection do
          post :update_order
        end
      end
    end

    resources :hard_links, :except => [:index, :show]
    resources :soft_links, :except => [:index, :show]

    resources :nodes, :only => [:edit, :update]

    resources :widget_templates

    resources :feed_widgets do 
      member do
        get :replace
      end
    end

    resources :slideshow_widgets do
      member do
        get :replace
      end
    end

    resources :snippets do
      member do
        get :replace
        put :revert
      end
    end

    resources :banners, :except => :show do
      member do
        get :manage
      end
    end

    resources :forums do
      collection do 
        post :update_order
      end
      member do 
        get :layouts
        put :change_layout 
      end
    end

    resources :faqs do
      collection do
        post :update_order
      end
      resources :questions do
        collection do
          post :update_order
        end
      end
    end

    resources :event_types do
      collection do
        post :update_order
      end
    end

    resources :blogs do
      collection do 
        post :update_order
      end
      member do 
        get :layouts
        put :change_layout
      end
    end

    resources :layouts do
      resources :user_pages, :path => 'pages', :only => [:new, :create]
    end

    scope :path => :email do
      resources :email_deliveries, :path => 'deliveries', :only => [:index, :new, :show] do
        collection { post :form }
      end
      resources :mailing_lists,    :path => 'lists', :except => :show 

      resources :system_emails,    :path => 'system', :except => :show do
        member { put :send_email }
      end

      get '/reports', :to => 'email_reports#index', :as => 'email_reports'

      resources :user_emails,      :path => 'templates', :except => :show do
        resources :email_deliveries, :path => 'deliveries', :only => [:create, :new]

        collection { get :select }
        member do
          put :send_email
          get :personalize
        end
      end
    end
    
    namespace :settings do
      resource  :general, :only => [:show, :update]
      resource  :content, :only => [:show, :update]
      resource  :email,   :only => [:show, :update], :controller => 'email'
      resource  :social,  :only => [:show, :update] do
        member do
          get :facebook_callback
          #get :twitter_callback
          #get :twitter_authorize
        end
      end
    end

    scope :path => :settings do
      resources :share_sites do
        collection do
          post :update_order
        end
        member do
          put :toggle_enabled
        end
      end
    end

    resources :searches, :path => 'search_log', :only => :index
    resource :help, :controller => 'help', :only => :show
  end

  # redirecting admin top menus to default sub menus
  get '/admin', :to => redirect('/admin/dashboard')
  get '/admin/email', :as => :admin_email, :to => redirect('/admin/email/templates')
  #get '/admin/content', :as => :admin_content, :to => redirect('/admin/content/pages')
  get '/admin/settings', :as => :admin_settings, :to => redirect('/admin/settings/general')

  # redirect menu show to its submenus
  get '/admin/menus/:id', :to => redirect('/admin/menus/%{id}/submenus')
  get '/admin/menus', :to => redirect('/admin/menus/main/submenus')

  # redirect show to edit on resources that don't have show
  # NOTE it would probably be appropriate to just treat #show as #edit throughout the system, as it has become the paradigm
  get '/admin/soft_links/:id', :to => redirect('/admin/soft_links/%{id}/edit')
  get '/admin/hard_links/:id', :to => redirect('/admin/hard_links/%{id}/edit')
  get '/admin/pages/:id', :to => redirect('/admin/pages/%{id}/edit')
  get '/admin/blog_posts/:id', :to => redirect('/admin/blog_posts/%{id}/edit')
  get '/admin/slides/:id', :to => redirect('/admin/slides/%{id}/edit')
  get '/admin/system_pages/:id', :to => redirect('/admin/system_pages/%{id}/edit')
  get '/admin/banners/:id', :to => redirect('/admin/banners/%{id}/edit')
  get '/admin/email/pending/:id', :to => redirect('/admin/email/pending/%{id}/edit')
  get '/admin/email/system/:id', :to => redirect('/admin/email/system/%{id}/edit')
  get '/admin/email/lists/:id', :to => redirect('/admin/email/lists/%{id}/edit')
  get '/admin/users/:id', :to => redirect('/admin/users/%{id}/edit')

  # redirect /topics to /topics/new (in case of non form submit refresh on /topics, mainly)
  get '/topics', :to => redirect('/topics/new')

  # Comment paths
  get '/topics/:id#c:comment_id',          :as => :topic_comment,          :to => 'topics#show'
  get '/:id#c:comment_id',                 :as => :page_comment,           :to => 'pages#show'
  get '/slides/:id#c:comment_id',          :as => :slide_comment,          :to => 'slides#show'
  get '/blogs/:blog_id/:id/#c:comment_id', :as => :blog_blog_post_comment, :to => 'blog_posts#show'

  # page/blog_post catchall, note that pages controller *does not* use :id, but @path, which is resolved after, so the :id here is irrelevant
  get '/:id', :to => 'pages#show', :as => :page, :constraints => PermalinkExistsConstraint.new

  root :to => "pages#show"

  get '/errors/test', :to => 'errors#test'

  # NOTE catchall route is defined in the engine
end
