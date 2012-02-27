require 'action_controller'

HTML::WhiteListSanitizer.allowed_tags = %w(sup sub b strong i em a).to_set
