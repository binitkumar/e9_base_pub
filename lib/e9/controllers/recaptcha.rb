module E9::Controllers
  #
  # Adds recaptcha functionality to a RESTful type controller.  It
  # depends on set_resource_ivar to set the current resource in a before
  # filter.
  #
  # It adds a simple validation to its resource class, forcing `captcha` to
  # be empty.  Then in the filter, if recaptcha is invalid, it simply gives
  # the resource's captcha field a value, making it invalid.  In this way
  # the records are still valid in non-captcha situations.
  #
  module Recaptcha
    extend ActiveSupport::Concern

    mattr_accessor :captcha_pass_value

    included do
      unless resource_class.ancestors.member?(CaptchaAccessor)
        resource_class.send(:include, CaptchaAccessor)
      end

      before_filter :check_recaptcha_validity, :only => [:create, :update], :if => :add_captcha_filter?
    end

    protected

      def add_captcha_filter?
        use_captcha?(controller_name)
      end

      def check_recaptcha_validity
        object = params[:action] == 'update' ? resource : build_resource
        object.captcha = 'invalid!' unless recaptcha_valid?
        set_resource_ivar(object)
      end

    module CaptchaAccessor
      extend ActiveSupport::Concern

      included do
        attr_writer :captcha

        def captcha
          @captcha.to_s
        end

        validates :captcha, :format => { :with => /\A\Z/ }
      end
    end
  end
end
