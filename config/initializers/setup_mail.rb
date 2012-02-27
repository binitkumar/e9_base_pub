require 'mail'
require 'e9/send_grid_client'

if Rails.env.development?
  Mail.register_interceptor(DevelopmentMailInterceptor)
end

ActionMailer::Base.smtp_settings = {
  # per client settings are in E9::Config, and merged each send
  :port                 => 587,
  :authentication       => 'plain',
  :enable_starttls_auto => true,
  :address              => 'smtp.sendgrid.net'
}

Rails.application.config.after_initialize do
  unless Rails.env.development?
    Email.__metaclass__.
      handle_asynchronously :send_with_queue!

    EmailDelivery.__metaclass__.
      handle_asynchronously :deliver_with_queue!

    E9::SendGridClient.
      handle_asynchronously :handle_bounced_emails!
  end
end
