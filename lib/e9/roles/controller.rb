module E9::Roles
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def filter_access_to_content(options = {})
        context = options.delete(:public_readable) ? :roled_public_readable : :roled

        filter_access_to :all, 
                         :attribute_check => true, 
                         :load_method     => :resource_for_auth,
                         :context         => context
      end

      #
      # exact - whether the result should be restricted exactly to the role passed
      #
      def has_role_scope(options = {})
        options.symbolize_keys!
        custom_options = options.slice!(:type, :only, :except, :if, :unless, :default, :as, :using, :allow_blank)

        options.reverse_merge!(
          :as      => 'role',
          :default => E9::Roles.bottom,
          :only    => [:show, :index]
        )

        has_scope :for_roleable, options do |controller, scope, value|
          controller.send(:_has_role_scope, scope, value, custom_options)
        end
      end
    end

    def _has_role_scope(scope, value, opts)
      if current_user_or_public_role.includes?(value)
        opts[:exact] ? scope.where(:role => value) : scope.for_roleable(value)
      else
        scope.where('1=0')
      end
    end

    def resource_for_auth
      params[:id] ? resource : build_resource
    end

    protected :_has_role_scope, :resource_for_auth
  end
end
