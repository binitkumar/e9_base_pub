module E9::Controllers
  #
  # This module is dependent on javascript code in base.js
  #
  module CheckboxCaptcha
    extend ActiveSupport::Concern

    HumanKey   = :cb_optin_1
    SpambotKey = :cb_optin_2

    included do
      before_filter :checkbox_captcha_test, :only => [:create, :update]

      # NOTE these helpers are mixed into base in rails extensions
      #helper HelperMethods
    end

    def checkbox_captcha_test
      tmpl, object = if params[:id]
        ['edit', resource]
      else
        ['new', build_resource]
      end

      unless object.respond_to?("#{HumanKey}=")
        class << object; attr_accessor HumanKey end
      end

      object.send("#{HumanKey}=", params[HumanKey])

      if checkbox_captcha_failure?
        if spambot_key_checked?
          # If the spambot key is checked this is almost certainly a bot, and we
          # want to redirect them away thinking it was successful.
          notice = I18n.t(:notice, :scope => :"flash.actions.#{params[:action]}", :resource_name => resource_instance_name)

          respond_with(object, :notice => notice) do |format|
            format.js { head 205 }
            format.html { redirect_to(root_url) }
          end
        else
          # otherwise if the human key is missing, we want to stop this and return
          # with an error immediately.  Note that in the offer forms, the presence
          # of the human key is validated client side.
          alert = 'Please check the box to verify that you are a real person'
          
          object.errors.add(:base, alert)

          respond_with(object, :alert => alert) do |format|
            format.html { render(tmpl) }
          end
        end

        flash_to_headers
        false
      end
    end

    def spambot_key_checked?
      params[SpambotKey].present?
    end

    def human_key_missing?
      not params[HumanKey].present?
    end

    def checkbox_captcha_failure?
      spambot_key_checked? || human_key_missing?
    end

    protected :checkbox_captcha_test, :spambot_key_checked?, 
        :human_key_missing?, :checkbox_captcha_failure?

    module HelperMethods
      def checkbox_captcha(resource = nil)
        checked = resource.respond_to?(HumanKey) && resource.send(HumanKey)

        content_tag('div', nil, :class => 'cbc', 'data-checked' => checked)
      end
    end
  end
end
