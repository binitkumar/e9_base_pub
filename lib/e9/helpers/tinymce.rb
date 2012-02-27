module E9::Helpers
  module Tinymce
    extend ActiveSupport::Concern

    STYLESHEET            = 'tinymce'
    PAGE_BREAK_SEPARATOR  = "<!-- PAGE_BREAK -->"
    TINY_MCE_DEFAULT_TAGS = %w(
                              page_title 
                              page_url 
                              signed_in_as 
                              site_name 
                              welcome_firstname 
                              welcome_username
                            )

    mattr_accessor :ignore_in_development
    @@ignore_in_development = false

    included do
      helper_method :use_tiny_mce?, :tiny_mce_options
    end

    module ClassMethods
      def use_tiny_mce(*args)
        options = args.extract_options!

        before_filter(options) do
          @_use_tiny_mce = !Rails.env.development? || !Tinymce.ignore_in_development

          @_tiny_mce_absolute_urls  = !!options.delete(:use_absolute_urls)
          @_tiny_mce_use_stylesheet = !!!options.delete(:unstyled)

          # skip_default tags?
          @_tiny_mce_liquid_tags = options.delete(:skip_default) ? [] : TINY_MCE_DEFAULT_TAGS

          # default_tags | passed tags
          @_tiny_mce_liquid_tags = @_tiny_mce_liquid_tags | Array.wrap(options.delete(:tags)) if options[:tags]
        end
      end
    end

    protected

    ##
    # helper to determine whether or not to load the tiny_mce code partial
    #
    def use_tiny_mce?
      !!@_use_tiny_mce
    end

    def tiny_mce_options
      {}.tap do |options|
        options[:template_external_list_url] = templates_path(:tags => @_tiny_mce_liquid_tags)
        options[:pagebreak_separator] = PAGE_BREAK_SEPARATOR

        if @_tiny_mce_use_stylesheet
          options[:content_css] = "/stylesheets/#{STYLESHEET}.css"
          asset_id = ENV['RAILS_ASSET_ID'] || DateTime.now.to_i
          options[:content_css] << "?#{asset_id}"
        end

        if @_tiny_mce_absolute_urls
          options[:document_base_url]  = base_url
          options[:relative_urls]      = false
          options[:remove_script_host] = false
        end
      end
    end
  end
end
