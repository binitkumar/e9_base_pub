require 'e9_base'
require 'e9_crm'

E9Crm.configure do |config|
  config.logging              = true
  config.user_model           = User
  config.tracking_controllers << PublicFacingController
end
