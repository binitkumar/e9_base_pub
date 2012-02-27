class Mailer < ActionMailer::Base
  include SendGrid
  sendgrid_enable :opentrack

  default_url_options[:host] = E9::Config[:domain_name]

  def self.refresh_config!
    E9::Config.reload!
    self.default_url_options[:host] = E9::Config[:domain_name]
    self.smtp_settings.merge!({
      :address   => E9::Config[:smtp_url],
      :domain    => E9::Config[:smtp_domain],
      :user_name => E9::Config[:smtp_username],
      :password  => E9::Config[:smtp_password]
    })
  end

  def rendered_mail(email, opts = {})
    Linkable.with_default_url_options(self.class.default_url_options) do
      @email = email
      @email.from = @email.from.presence || E9::Config[:system_mailing_address]

      # mix in the default interpolation scope
      opts.reverse_merge!(E9::Liquid::Env.new)
      opts.symbolize_keys!

      # TODO mailer sets "self" as the liquid template's controller.
      #     This which works for url_for type calls but will break if say, 
      #     the email contained a tag that rendered a partial
      #
      Liquid::Template.registers[:controller] = self

      # pull out the mail arguments
      mail_args = opts.delete(:mail_args) || {}

      ##
      # merge any possible liquid vars then render the liquid template
      # columns (bodies and subject)
      #
      @email.options.merge!(opts)

      @text_body = @email.r(:text_body).html_safe

      @html_body = @email.r(:html_body)
      @html_body = Linkable.urlify_html(@html_body)
      @html_body = @html_body.gsub(/\r?\n/, '<br/>').html_safe

      mail_args.reverse_merge!(
        # NOTE simply set the :to the same as the :from
        #
        # SendGrid is determining recipients from the custom headers, so
        # the :to is ignored, but it still needs to be set regardless.
        :to       => @email.from,

        :subject  => @email.r(:subject),
        :reply_to => @email.reply_to,
        :from     => @email.from
      )

      ##
      # If there's no `to` then this is a multiple recipient
      # email using the sendgrid API
      #
      sendgrid_recipients @email.merges[:email]

      @email.substitutions.each do |variable, array|
        array.map! {|v| v.is_a?(Array) ? send(v.shift, *v) : v }
        sendgrid_substitute "##{variable}#", array
      end
      
      mail(mail_args) do |format|
        if @email.plain_text?
          format.text { render :text => @text_body }
          format.html { render :text => @html_body }
        else
          format.text
          format.html
        end
      end
    end
  end
end
