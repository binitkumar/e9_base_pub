module E9::Helpers
  module ResourceLinks
    extend ActiveSupport::Concern

    TRANSLATION_KEYS = [:model, :models, :collection, :element]
    PATH_KEYS        = [:scope, :action, :method, :remote, :confirm, :class]

    included do
      class_attribute :route_scope

      helper HelperMethods
    end

    module HelperMethods
      delegate :route_scope, :to => :controller

      def parent
        controller.send(:parent) rescue nil
      end

      def parent?
        controller.send(:parent?) rescue false
      end

      def link_to_resource(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        options.symbolize_keys!

        resource, name = name_and_or_resource.reverse

        return '' unless [Class, ActiveRecord::Base].any? {|t| resource.is_a?(t) }

        translation_options = options.slice(:model, :models, :collection, :element)
        options.except!(:model, :models, :collection, :element)

        # probably need a better way to extract all possible link options
        path_options = options.slice!(:scope, :action, :method, :remote, :confirm, :class, :rel)

        klass  = resource.is_a?(Class) ? resource : resource.class

        action = (options.delete(:action) || :show).to_sym

        if klass == resource && ![:index, :new].member?(action)
          action = :index
        end

        # this is some hacky business.
        scopes = [*(options.delete(:scope) || route_scope), parent].compact

        begin
          path = 
            case action
            when :new
              new_polymorphic_path(scopes + [klass], path_options)
            when :edit
              edit_polymorphic_path(scopes + [resource], path_options)
            when :index
              polymorphic_path(scopes + [klass], path_options)
            else
              polymorphic_path(scopes + [resource], path_options)
            end

        rescue NoMethodError
          if scopes.member?(route_scope)
            scopes.delete(route_scope)
            retry
          elsif scopes.member?(parent)
            scopes.delete(parent)
            retry
          else
            raise $!
          end
        end

        mn = klass.model_name
        translation_options.reverse_merge!({
          :model      => mn.human,
          :models     => mn.human.pluralize,
          :collection => mn.collection,
          :element    => mn.element
        })
        
        if action == :destroy
          defaults = klass.lookup_ancestors.map {|k|
            :"#{klass.i18n_scope}.links.#{k.model_name.underscore}.confirm_destroy"
          } << :"#{klass.i18n_scope}.links.confirm_destroy"

          options[:method] = :delete
          options.reverse_merge!({
            :remote  => true, 
            :confirm => I18n.t(defaults.shift, translation_options.merge(:default => defaults))
          })
        end

        unless name.present?
          #
          # Mimic ActiveModel's lookup chain for attributes
          #
          defaults = klass.lookup_ancestors.map do |k|
            :"#{klass.i18n_scope}.links.#{k.model_name.underscore}.#{action}"
          end

          defaults << :"#{klass.i18n_scope}.links.#{action}"
          defaults << action.to_s.humanize

          name = I18n.t(defaults.shift, translation_options.merge(:default => defaults))
        end

        link_to name, path, options
      end

      def link_to_show_resource(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        link_to_resource(*name_and_or_resource, options.merge(:action => :show))
      end

      def link_to_edit_resource(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        link_to_resource(*name_and_or_resource, options.merge(:action => :edit))
      end

      def link_to_new_resource(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        link_to_resource(*name_and_or_resource, options.merge(:action => :new))
      end

      def link_to_destroy_resource(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        link_to_resource(*name_and_or_resource, options.merge(:action => :destroy))
      end

      def link_to_collection(*name_and_or_resource)
        options = name_and_or_resource.extract_options!
        link_to_resource(*name_and_or_resource, options.merge(:action => :index))
      end
    end
  end
end
