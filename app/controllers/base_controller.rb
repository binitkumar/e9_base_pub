require 'rack/recaptcha'

module BaseController
  extend ActiveSupport::Concern

  include E9::Roles::Controller

  include E9::Helpers::Breadcrumbs
  include E9::Helpers::GoogleBomb
  include E9::Helpers::Tinymce
  include E9::Helpers::Translation
  include E9::Helpers::Urls
  include E9::Helpers::ResourceLinks

  include E9::Controllers::Layout

  include Rack::Recaptcha::Helpers

  def BaseController.current_controller
    Thread.current['controller']
  end

  def BaseController.current_controller=(controller)
    Thread.current['controller'] = controller
  end

  included do
    #before_filter :set_p3p
    
    attr_reader :pagination_parameters, :current_page

    before_filter { BaseController.current_controller = self }

    # for declarative_authorization
    before_filter {|c| Authorization.current_user = c.current_user }

    # solve caching issues by forcing the load at the onset?
    before_filter { E9::Config.reload! }

    before_filter {|c| Linkable.default_url_options = c.url_options }

    before_filter :check_for_old_browsers
    before_filter :set_pagination_parameters
    before_filter :set_liquid_controller
    before_filter :set_locale
    before_filter :set_timezone
    before_filter :prepare_path
    before_filter :find_current_page
    before_filter :store_referrer_from_params
    before_filter :liquid_env
    before_filter :set_mailer_host

    before_filter :add_home_crumb, :if => :show_home_breadcrumb?

    if Rails.env.production?
      rescue_from ActiveRecord::RecordNotFound, :with => :render_404

      # this is handled by routes and errors controller
      #rescue_from ActionController::RoutingError, :with => :render_404
    end

    after_filter :flash_to_headers
    after_filter :debug_logger

    HELPER_METHODS = [
      :liquid_env,
      :base_url,
      :query_params,
      :public_role,
      :current_user_or_public_role,
      :true_value?, :false_value?,
      :store_referrer_params,
      :store_location,
      :paging_page, 
      :pagination_per_page,
      :render_in_html_lookup_context
    ]

    helper_method *HELPER_METHODS

    ##
    # Override Devise methods
    #

    # called to determine path after a user signs in
    def after_sign_in_path_for(resource_or_scope)
      if resource_or_scope.is_a?(User)
        resource_or_scope.role.includes?('administrator') ? notes_url : profile_path
      else
        super 
      end
    end

    def after_sign_out_path_for(resource_or_scope)
      root_url
    end
  end

  module ClassMethods
    JS_SKIPPABLE_BEFORE_FILTERS = [:check_for_old_browsers, :find_current_page, :store_referrer_from_params, :add_home_crumb ]

    def skip_js_skippable_filters(opts = {})
      skip_before_filter *(JS_SKIPPABLE_BEFORE_FILTERS << opts)
    end
  end
    
  protected

  def set_p3p
    response.headers["P3P"] = %q/CP="CAO PSA OUR"/
  end

  def set_no_caching
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Pragma"]        = "no-cache"
  end

  def query_params
    params.except(:controller, :action, :utf8)
  end

  def public_role
    @_public_role ||= E9::Roles.public
  end

  def current_user_or_public_role
    @_current_user_or_public_role ||= [current_user.role, public_role].max
  end


  TRUE_VALUES  = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON']
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF']

  def true_value?(v)
    TRUE_VALUES.member?(v)
  end

  def false_value?(v)
    FALSE_VALUES.member?(v)
  end

  #
  # sends a custom header to flash that can be intercepted and used in ajax methods
  #
  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Flash-Alert']  = flash[:alert]  if flash[:alert]
    response.headers['X-Flash-Notice'] = flash[:notice] if flash[:notice]
    flash.discard
  end

  def debug_logger
    if current_page.present?
      Rails.logger.info("Rendered Page ID:#{current_page.id} (#{current_page.title})")
    end
  end

  def xhr?
    request.xhr?
  end

  def prepare_path
    # NOTE prepare_path takes the "nl" no layout route into account for pages
    @path = request.path.sub(/^\/(nl\/)?/,'')
  end

  def find_current_page
    @current_page ||= SystemPage.master
  end
  #alias :current_page :find_current_page

  def liquid_env(force = false)
    @_liquid_env = nil if force
    @_liquid_env ||= begin
      E9::Liquid::Env.new.tap do |env|
        env[:current_url]  = env[:url] = request.url

        if @current_page.present?
          env[:current_page] = env[:page] = @current_page

          env[:next_page]     = @current_page.try(:next_record)
          env[:previous_page] = @current_page.try(:previous_record)
        end

        if current_user.present?
          env[:current_user] = env[:user] = current_user
        end
      end
    end
  end

  def set_liquid_controller
    Liquid::Template.registers[:controller] = self
  end

  def initialize_favorite(favoritable)
    if favoritable.kind_of?(Favoritable)
      @favorite = Favorite.for_user_and_favoritable(current_user, favoritable)
    end
  end

  # TODO user based locale?
  def set_locale
    #I18n.locale = params[:lang] ? params[:lang] : I18n.default_locale
  end

  # TODO implement local timezone
  def set_timezone
    Time.zone = Time.zone_default
  end


  ##
  # Storing return_to
  #
  
  # 
  # merged into url params the controller will store the referring page
  # for later use with redirect_to_back_or
  #
  def store_referrer_params
    { store_referrer_param_name => 1 }
  end
  
  def store_referrer
    session[:return_to] = request.referrer
  end

  SNOWMAN_NAME = "utf8"

  # store_location is just like storing referrer except it stores
  # the current path.  This is more useful for controller filters
  def store_location
    session[:return_to] = begin
      if !request.query_string.empty?
        "#{request.path}?#{Rack::Utils.parse_query(request.query_string).slice!(SNOWMAN_NAME).to_query}"
      else
        request.path
      end
    end
  end

  def clear_return_to
    session[:return_to] = nil
  end
  alias :clear_location :clear_return_to

  def store_referrer_param_name
    'recall'
  end

  def store_referrer_from_params
    if params.delete(store_referrer_param_name)
      store_referrer_with_scope
    end
  end

  def store_referrer_with_scope
    store_path_with_scope(request.referrer)
  end

  def store_path_with_scope(path = nil)
    session[:"#{current_scope_with_fallback}_return_to"] = path || request.path
  end

  def clear_path_with_scope
    session[:"#{current_scope_with_fallback}_return_to"] = nil
  end

  def current_scope_return_to
    session[:"#{current_scope_with_fallback}_return_to"]
  end

  def current_scope_with_fallback
    env['warden.options'][:scope] rescue 'user'
  end

  #
  # redirects to session[:return_to] if possible or the url_for param(s) in default
  #
  # "match" is the default behavior, which serves to prevent redirection to unexpected places.
  # It assumes the typical case of "back or default" is that "back" is actually the same
  # as "default", only with previously stored query parameters.
  #
  # Primarily this function exists to go "back" to saved query results on index pages.
  #
  # Passing match => false will not attempt to make this match, and will redirect to any
  # data stored in return to, which can cause unexpected behavior.
  #
  # NOTE this function always deletes return_to from the session
  #
  def redirect_to_back_or(default, opts = {:match => true})
    redirect_to(back_or_default_path(default, opts)) and return false
  end

  def back_or_default_path(default, opts = {:match => true})
    if (return_to = session.delete(:return_to)) && opts[:match]
      begin
        return_to = nil if URI.parse(return_to).path != URI.parse(url_for(default)).path
      rescue URI::InvalidURIError => e
      end
    end

    return_to || default
  end

  ##
  # Rendering
  #
  def render_send_file(path, filename, type = "application/octet-stream")
    if %w(production staging).include?(Rails.env)
      path.gsub!(/#{Rails.root}\/public/, "")

      head(:x_accel_redirect    => path,
           :content_type        => type,
           :content_disposition => "attachment; filename=\"#{filename}\"")

    else
      send_file(path, :filename => filename, :type => type)
      render :nothing => true unless performed?
    end
  end

  def render_403(*args)
    opts = args.extract_options!
    render({:file => "/public/403.html", :status => 403, :layout => false }.merge(opts))
  end

  def render_404(*args)
    opts = args.extract_options!

    if url = landing_page_redirect_url
      redirect_to url and return false
    else
      respond_to do |format|
        format.js { head 404 }

        format.html do
          # try to find the 404 system_page
          render_args = if @current_page = Page.not_found

            # TODO this is a regular mess, should probably have its own control
            clear_breadcrumbs
            add_home_crumb
            add_breadcrumb!(@current_page.title)

            { :template => 'pages/show', :status => 404, :layout => @current_page.layout.template, :locals => { :resource => @current_page, :resource_class => @current_page.class } }
          else
            { :template => 'errors/404', :status => 404, :layout => 'simple' }
          end

          render render_args.merge(opts) and return false
        end
      end
    end
  end

  ##
  # Pagination and defaults
  #
  def set_pagination_parameters
    options = pagination_defaults
    @is_paging = !!params[pagination_page_param]
    options[pagination_page_param] = params[pagination_page_param] if params[pagination_page_param]
    options[:per_page]  = params.delete(:per_page) if params[:per_page]
    @pagination_parameters = options
  end

  def paging_page
    pagination_parameters[pagination_page_param] || 1
  end

  def paging?
    # TODO this was for search, to see if a "page" param had been passed originally (1 included).  I don't think it's used now?
    @is_paging
  end

  # NOTE in will_paginate for rails this this isn't yet properly implemented.  The option exists but #paginate method has :page hardcoded as the param
  def pagination_page_param
    WillPaginate::ViewHelpers.pagination_options[:param_name]
  end

  def pagination_per_page_default
    E9::Config[:records_per_page]
  end

  def pagination_per_page
    if request.format.to_s =~ /rss/
      50
    else
      pagination_per_page_default
    end
  end
  # TODO why is this public?
  public :pagination_per_page

  def pagination_defaults
    {
      pagination_page_param => 1,
      :per_page => pagination_per_page
    }
  end

  ##
  # declarative_authorization: 
  #
  # called when a user has insufficient priveleges for an action
  def permission_denied
    flash[:alert] = I18n.t(current_user ? :access_denied : :unauthenticated, :scope => :"devise.failure")

    respond_to do |format|
      format.js { head 401 }
      format.xml { head 401 }
      format.html do 
        if request.xhr?
          head 401
        else 
          store_path_with_scope
          redirect_to(permission_denied_fallback_url)
        end
      end
    end
  end

  def permission_denied_fallback_url
    if !current_user
      new_user_session_url
    elsif request.headers["Referer"].present?
      :back
    else
      root_url
    end
  end

  ##
  # Browser check and cookie
  #
  BROWSER_CHECK_COMPLETE_COOKIE = 'browser_check_complete'

  def check_for_old_browsers
    if request.path == '/'
      unless cookies[BROWSER_CHECK_COMPLETE_COOKIE]
        cookies[BROWSER_CHECK_COMPLETE_COOKIE] = "completed"

        if browser_is_old?
          respond_to do |format|
            format.html do
              render :template => 'errors/older_browser_alert', :layout => 'simple'
            end
          end

          return false
        end
      end
    end
  end

  def browser_is_old?
    ua = request.env['HTTP_USER_AGENT']

    if ua =~ /MSIE (\d)/ && $1.to_i <= 7
      true
    end
  end

  def show_home_breadcrumb?
    @current_page.try :show_home_breadcrumb?
  end

  ##
  # Breadcrumb method overrides
  #
  
  def add_dynamic_breadcrumbs
    if current_page.present? && current_page.has_own_breadcrumbs?
      current_page.menu_ancestors.each do |menu| 
        add_breadcrumb( proc {|v| v.menu_link_text(menu) }, proc {|v| v.menu_link_href(menu) } ) 
      end
      add_breadcrumb! current_page.title if current_page.title
    end
  end

  def add_home_crumb
    add_breadcrumb e9_t(:home_title), :root_path
  end

  def add_index_breadcrumb(opts = {})
    if respond_to?(:resource_class)
      add_breadcrumb e9_t(:index_title), polymorphic_path(resource_class)
    end
  end

  def add_show_breadcrumb(opts = {})
    add_breadcrumb! e9_t(:show_title)
  end

  def add_new_breadcrumb(opts = {})
    add_breadcrumb! e9_t(:new_title)
  end

  def add_edit_breadcrumb(opts = {})
    add_breadcrumb! e9_t(:edit_title)
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host if Rails.env.development?
  end

  def base_url
    "http://#{request.host_with_port}"
  end

  def flash_is_error?
    !flash[:alert].blank?
  end

  def handle_unacceptable_mimetype
    format = request.format.blank? || request.format == Mime::ALL ? Mime::HTML : request.format

    unless collect_mimes_from_class_level.member?(format.to_sym)
      respond_to do |format|
        format.html { render_404 }
        format.js   { head 503   }
        format.json { head 503   }
      end

      return false
    end
  end

  def render_in_html_lookup_context
    lookup_context.update_details(:formats => [Mime::HTML.to_sym]) do
      yield
    end
  end
end
