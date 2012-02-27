require 'devise'
require 'devise_revokable'

DeviseRevokable.mailer = lambda {|method_name, resource|
  begin
    email = ::SystemEmail.send(method_name)
    email.send!(resource)
  rescue => e
    Rails.logger.error("DeviseRevokable Mail Send Error: #{e}")
  end
}
