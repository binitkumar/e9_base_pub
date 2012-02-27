require 'rest-client'
require 'json'
require 'warden'
require 'delayed_job'
require 'active_support/hash_with_indifferent_access'

module E9
  class SendGridClient
    CONFIG_PATH = File.join(E9Base::Engine.root, 'config', 'send_grid.yml')
    API_V1      = 'https://sendgrid.com/api'
    API_V2      = 'https://sendgrid.com/apiv2'

    def self.config
      @_config ||= HashWithIndifferentAccess.new {|k, v| ENV["SENDGRID_#{v}".upcase] }
    end

    delegate :config, :to => 'self.class'

    # v1 Web API

    def stats(options = {})
      post_as_subuser(api_v1, 'stats.get.json', options)
    end

    def bounces(options = {})
      method = options.delete(:method) || 'get'
      options.reverse_merge!(:type => 'hard')
      post_as_subuser(api_v1, "bounces.#{method}.json", options)
    end

    # Subuser API
    
    def limit(options = {})
      options.merge!(:task => 'retrieve')
      post_for_subuser(api_v2, 'customer.limit.json', options)
    end

    def handle_bounced_emails!
      with_rescue do
        emails = bounces.map {|bounce| bounce['email'] }
        User.handle_bounced_emails!(emails)
        bounces(:method => 'delete')
      end
    end

    protected

      def api_v1; @api_v1 ||= RestClient::Resource.new(API_V1) end
      def api_v2; @api_v2 ||= RestClient::Resource.new(API_V2) end

      def user_credentials
        {:api_user => config[:api_user], :api_key => config[:api_key]}
      end

      def subuser_credentials
        {}.tap do |hash|
          hash[:api_user] = E9::Config[:smtp_username]
          hash[:api_key]  = E9::Config[:smtp_password]
        end
      end

      def post_as_subuser(api, endpoint, options = {})
        options.merge! subuser_credentials
        _do_post api, endpoint, options
      end

      def post_for_subuser(api, endpoint, options = {})
        options.merge! user_credentials
        options.merge! :user => subuser_credentials[:api_user]
        _do_post api, endpoint, options
      end

    private

      def _do_post(api, endpoint, options = {})
        JSON.parse api[endpoint].post(options)
      end

      def with_rescue
        yield
      rescue => e
        Rails.logger.error("E9::SendGridClient Error: #{e}")
        e
      end

    Warden::Manager.after_authentication do |record, warden, options|
      if !Rails.env.development? && record.respond_to?(:role) && record.role >= :administrator
        E9::SendGridClient.new.handle_bounced_emails!
      end
    end
  end
end
