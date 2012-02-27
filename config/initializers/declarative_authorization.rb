require 'declarative_authorization'
require 'active_record/base'

# fall back to the gem's auth rules if their config is not found locally
unless File.exists?(File.join(Rails.root, 'config', 'authorization_rules.rb'))
  module Authorization
    remove_const(:AUTH_DSL_FILES) if const_defined?(:AUTH_DSL_FILES)
    AUTH_DSL_FILES = ["#{E9Base::Engine.root}/site/config/authorization_rules.rb"]
  end
end

# we never want the rule browser
Authorization.instance_eval do
  def activate_authorization_rules_browser?; false end
end

# util method to get around auth in models
module E9Base::DeclarativeAuthorization
  extend ActiveSupport::Concern

  delegate :without_access_control, :to => 'self.class'

  module ClassMethods
    def without_access_control
      Authorization.ignore_access_control(true)
      yield
    ensure
      Authorization.ignore_access_control(false)
    end
  end
end

ActiveRecord::Base.send(:include, E9Base::DeclarativeAuthorization)
