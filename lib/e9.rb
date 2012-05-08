require 'uuidtools'

module E9
  module ActiveRecord
    autoload :Anchorable,           'e9/active_record/anchorable'
    autoload :AttributeSearchable,  'e9/active_record/attribute_searchable'
    autoload :InheritableOptions,   'e9/active_record/inheritable_options'
    autoload :Initialization,       'e9/active_record/initialization'
    autoload :STI,                  'e9/active_record/sti'
    autoload :TimeScopes,           'e9/active_record/time_scopes'
  end

  module Controllers
    autoload :CheckboxCaptcha,      'e9/controllers/checkbox_captcha'
    autoload :InheritableViews,     'e9/controllers/inheritable_views'
    autoload :Commentable,          'e9/controllers/commentable'
    autoload :Orderable,            'e9/controllers/orderable'
    autoload :Recaptcha,            'e9/controllers/recaptcha'
    autoload :Sortable,             'e9/controllers/sortable'
    autoload :View,                 'e9/controllers/view'
  end

  module Models
    autoload :RecordSequence,       'e9/models/record_sequence'
    autoload :View,                 'e9/models/view'
  end

  module Helpers
    autoload :Breadcrumbs,          'e9/helpers/breadcrumbs'
    autoload :GoogleBomb,           'e9/helpers/google_bomb'
    autoload :ResourceLinks,        'e9/helpers/resource_links'
    autoload :Tinymce,              'e9/helpers/tinymce'
    autoload :Translation,          'e9/helpers/translation'
    autoload :Urls,                 'e9/helpers/urls'
  end

  autoload :Liquid,                 'e9/liquid'
  module Liquid
    autoload :Drops,                'e9/liquid/drops'
    autoload :Env,                  'e9/liquid/env'
    autoload :Filters,              'e9/liquid/filters'
    autoload :Tags,                 'e9/liquid/tags'
    autoload :Find,                 'e9/liquid/find'
  end

  module Rack
    autoload :WWWRedirect,          'e9/rack/www_redirect'
    autoload :Rerouting,            'e9/rack/www_redirect'
    autoload :NoSession,            'e9/rack/www_redirect'
  end

  autoload :Roles,                  'e9/roles'
  module Roles
    autoload :Role,                 'e9/roles/role'
    autoload :Roleable,             'e9/roles/roleable'
    autoload :Controller,           'e9/roles/controller'
  end

  autoload :Seeds,                  'e9/seeds'

  module Social
    autoload :Clients,              'e9/social/clients'
    autoload :Controller,           'e9/social/controller'

    module Clients
      autoload :Twitter,            'e9/social/clients/twitter'
      autoload :Facebook,           'e9/social/clients/facebook'
    end
  end

  autoload :AWS,                    'e9/aws'
  autoload :Carrierwave,            'e9/carrierwave'
  autoload :Config,                 'e9/config'
  autoload :DestroyRestricted,      'e9/destroy_restricted'
  autoload :Feedable,               'e9/feedable'
  autoload :HTML,                   'e9/html'
  autoload :HtmlSafeColumns,        'e9/html_safe_columns'
  autoload :ImageSpecification,     'e9/image_specification'
  autoload :Permalink,              'e9/permalink'
  autoload :Publishable,            'e9/publishable'
  autoload :SendGridClient,         'e9/send_grid_client'
  autoload :SimpleAttributeMethods, 'e9/simple_attribute_methods'

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON']
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF']

  class << self
    def uuid
      UUIDTools::UUID.timestamp_create.to_s
    end

    def true_value?(v)
      TRUE_VALUES.member?(v)
    end

    def false_value?(v)
      FALSE_VALUES.member?(v)
    end
  end
end
