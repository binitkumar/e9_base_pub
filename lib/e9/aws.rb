require 'active_support/hash_with_indifferent_access'

module E9
  module AWS
    def self.config
      @_config ||= begin
        HashWithIndifferentAccess.new {|k, v| ENV["AWS_#{v}".upcase] }
      end
    end
  end
end
