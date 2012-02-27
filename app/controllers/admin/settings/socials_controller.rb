require 'oauth2'

class Admin::Settings::SocialsController < Admin::SettingsController
  defaults :instance_name => 'settings', :resource_class => Settings

  filter_access_to :facebook_callback, :require => :update, :context => :admin

  prepend_before_filter do
    @code = params[:code]
  end

  def facebook_callback
    begin
      access_token = facebook_client.auth_code.get_token(@code, {
        :redirect_uri => facebook_redirect_uri,

        # this is crucial for the token intantiation, as the response is 
        # text/plain in the format of code=whatever and the oauth2 gem currently
        # does not know how to parse this into a hash
        :parse => :query
      })

      update_resource resource, 
          build_params.merge(:facebook_access_token => access_token.token)

    rescue => e
      Rails.logger.error("Response: #{e.response && e.response.inspect}")
      flash[:alert] = "There was an error authorizing facebook"
    end

    respond_with(resource) do |format|
      format.html { redirect_to :admin_settings_social }
    end
  end

  protected

    def build_params
      params[:settings] ||= {}
      params[:settings]
    end

    def add_index_breadcrumb
      add_breadcrumb! e9_t(:"admin.settings.socials.index_title")
    end

    ##
    # Twitter
    #
    # NOTE Twitter auth is no longer done through the admin panel, since you can 
    # simply get the twitter token through your Twitter admin panel.
    #

    ##
    # Facebook
    #

    def facebook_client
      @_facebook_client ||= begin
        _id, _secret = resource.facebook_app_id, resource.facebook_app_secret
      
        ::OAuth2::Client.new(_id, _secret, {
          :site => 'https://graph.facebook.com',

          # by default this would be /oauth/token
          :token_url => '/oauth/access_token',

          # Docs are vague on this, but I believe it may work with :post also
          :token_method => :get
        })
      end
    end

    # This generates the facebook authorization link for the settings form
    def facebook_auth_uri
      return '' unless E9::Config.instance.facebook_auth_ready?

      facebook_client.auth_code.authorize_url({
        :redirect_uri => facebook_redirect_uri,
        :scope        => 'publish_stream,manage_pages,offline_access'
      })
    end
    helper_method :facebook_auth_uri

    def facebook_redirect_uri
      facebook_callback_admin_settings_social_url
    end

end
