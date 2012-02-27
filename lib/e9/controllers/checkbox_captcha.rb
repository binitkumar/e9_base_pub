module E9::Controllers
  #
  # This module is dependent on javascript code in base.js
  #
  module CheckboxCaptcha
    extend ActiveSupport::Concern

    HumanKey   = :cb_optin_1
    SpambotKey = :cb_optin_2

    included do
      prepend_before_filter :checkbox_captcha_test, :only => [:create, :update]
      helper HelperMethods
    end

    def checkbox_captcha_test
      unless params[SpambotKey].nil? && params[HumanKey].present?
        flash[:notice] = I18n.t(:notice, :scope => :"flash.actions.#{params[:action]}", :resource_name => resource_instance_name)
        respond_with(build_resource) do |format|
          format.html { redirect_to(root_path) }
          format.js { head 205 }
        end

        false
      end
    end

    protected :checkbox_captcha_test

    module HelperMethods
      def checkbox_captcha
        content_tag('div', nil, :class => 'cbc')
      end
    end
  end
end
