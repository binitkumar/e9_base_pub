require 'rack/recaptcha'
require 'e9_base'

Rails.application.config.middleware.use(Rack::Recaptcha, {
  :public_key  => ENV['RECAPTCHA_PUBLIC_KEY'],
  :private_key => ENV['RECAPTCHA_PRIVATE_KEY']
})

module Rack
  class Recaptcha
    module Helpers

      alias :recaptcha_tag_without_ajax :recaptcha_tag

      def recaptcha_script(scope, options = {})
        return '' unless use_captcha?(scope)

        return if @recaptcha_script_rendered
        @recaptcha_script_rendered = true

        path = options[:ssl] ? Rack::Recaptcha::API_SECURE_URL : Rack::Recaptcha::API_URL
        %{<script type="text/javascript" src="#{path}/js/recaptcha_ajax.js"></script>}.html_safe
      end

      def recaptcha_tag(scope, type = :noscript, options = {})
        # Simply return if config is set to skip captcha
        return '' unless use_captcha?(scope)

        options = DEFAULT.merge(options)
        options.reverse_merge!(:display => { :theme => 'white' })

        options[:public_key] ||= Rack::Recaptcha.public_key
        path = options[:ssl] ? Rack::Recaptcha::API_SECURE_URL : Rack::Recaptcha::API_URL
        params = "k=#{options[:public_key]}"
        error_message = request.env['recaptcha.msg'] if request
        params += "&error=" + URI.encode(error_message) unless error_message.nil?
        html = case type.to_sym
        when :challenge
          %{<script type="text/javascript" src="#{path}/challenge?#{params}">
            </script>}.gsub(/^ +/, '')
        when :noscript
          %{<noscript>
            <iframe src="#{path}/noscript?#{params}" height="#{options[:height]}" width="#{options[:width]}" frameborder="0"></iframe><br>
            <textarea name="recaptcha_challenge_field" rows="#{options[:row]}" cols="#{options[:cols]}"></textarea>
            <input type="hidden" name="recaptcha_response_field" value="manual_challenge">
            </noscript>}.gsub(/^ +/, '')
        when :ajax
          %{<div id="ajax_recaptcha"></div>
            <script type="text/javascript">
              $(function() {
                Recaptcha.create('#{options[:public_key]}', document.getElementById('ajax_recaptcha')#{options[:display] ? ', RecaptchaOptions' : ''});
              });
            </script>}.gsub(/^ +/, '')
        else
          ''
        end
        if options[:display]
          %{<script type="text/javascript">
            var RecaptchaOptions = #{options[:display].to_json};
            </script>}.gsub(/^ +/, '')
        else
          ''
        end + html
      end

      def use_captcha?(scope)
        E9::Config[:"use_captcha_#{scope}"]
      end
    end
  end
end
