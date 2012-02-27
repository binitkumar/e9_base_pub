module E9Crm
  module TrackingController
    extend ActiveSupport::Concern

    included do
      after_filter :track_page_view
    end

    protected 

    #
    # Track a page view and associate it with the loaded cookie.
    #
    # === Notable paramters
    #
    # [:new_visit]    This is stored in the session during tracking cookie creation
    #                 if the tracking cookie is either new, or changing campaigns
    #                 because a user is visiting on a different code.
    #
    # [:campaign]     The campaign associated with the tracking cookie or the default
    #                 campaign (typically the NoCampaign record)
    #
    def track_page_view

      # NOTE we cache the original session id because upon login, the session_id
      # changes to prevent session fixation attacks.
      session[:sid] ||= request.session_options[:id]

      if request.get? && !PageView.exists?(:session => session[:sid])
        @_page_view ||= tracking_cookie.page_views.create({
          :session      => session[:sid],
          :request_path => request.fullpath,
          :user_agent   => request.user_agent,
          :referer      => request.referer,
          :remote_ip    => request.remote_ip,
          :campaign     => tracking_campaign,
          :new_visit    => session[:new_visit].present?
        })
      end
    end
  end
end
