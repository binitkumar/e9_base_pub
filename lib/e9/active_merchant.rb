require 'active_merchant'

module E9
  module ActiveMerchant
    def self.config
      E9::Config
    end

    def self.gateway_params
      {}.tap do |params|
        params[:login] = config[:m_gateway_login]
        params[:password] = config[:m_gateway_pass]

        if config[:m_gateway_test]
          params[:test] = true
        end
      end
    end

    def self.gateway
      begin
        raise 'Gateway Not Defined' unless config[:m_gateway]
        gateway_class = "active_merchant/billing/#{config[:m_gateway]}_gateway".classify.constantize
        gateway_class.new(gateway_params)
      rescue => e
        Rails.logger.error("E9::ActiveMerchant - Error building gateway: #{e}")
        nil
      end
    end
  end
end
