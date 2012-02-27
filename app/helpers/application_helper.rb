module ApplicationHelper
  include Rack::Recaptcha::Helpers

  def kramdown(string)
    rendered = render_liquid(string)
    kdoc     = Kramdown::Document.new(rendered)

    raw kdoc.to_html
  end

  alias :k :kramdown

  def help_tooltip(string, data_title = nil)
    return <<-HTML.strip.html_safe
      <span class="help" rel="tooltip" #{data_title ? %Q[data-title="#{data_title}"] : nil } title="#{CGI.escape_html(string)}">#{t(:inline_help_link)}</span>
    HTML
  end

  def help_label(form_or_id, key, options = {})
    options[:key] ||= :"#{key}_help"

    help_title = options.delete(:title) || resource.class.human_attribute_name(options.delete(:key))
    help_title << I18n.t(:markdown_help) if options[:markdown]

    str = ''.html_safe
    str.safe_concat options.delete(:text) || resource.class.human_attribute_name(key)
    str.safe_concat ' '
    str.safe_concat help_tooltip(help_title, options.delete(:header))

    if form_or_id.respond_to?(:label)
      form_or_id.label(key, str, options)
    else
      label_tag(form_or_id, str, options)
    end
  end

  def resource_with_rescue
    defined?(resource) && resource
  end

  def google_site_verification_meta_tag
    unless (code = E9::Config[:google_site_verification_code]).blank?
      tag :meta, :name => 'google-site-verification', :content => code
    end
  end

  def meta_tags(*args)
    if args.empty?
      @_meta_keywords = @_meta_keywords.join(', ') if @_meta_keywords.kind_of?(Array)

      keywords    = @_meta_keywords.blank?    ? E9::Config[:default_meta_keywords]    : @_meta_keywords
      description = @_meta_description.blank? ? E9::Config[:default_meta_description] : @_meta_description

      ''.html_safe.tap do |html|
        html << tag(:meta, :name => 'description', :content => description)
        html << tag(:meta, :name => 'keywords',    :content => keywords)
      end
    elsif args.length == 2
      @_meta_description, @_meta_keywords = args
    elsif arg = args.shift
      @_meta_description, @_meta_keywords = arg.meta_description, arg.meta_keywords
    end
  end

  def meta_description=(v)
    @_meta_description = v
  end

  def meta_keywords=(v)
    @_meta_keywords = v
  end

  def query_params
    params.except(:action, :controller)
  end
  
  def spinner
    image_tag('spinner.gif', :alt => "Loading!", :class => "spinner", :style => "display: none")
  end

  def session_key_hash
    { session_key => session_id }
  end

  def authenticity_token_hash
    { request_forgery_protection_token => form_authenticity_token }
  end

  def session_key
    Rails.configuration.send(:session_options)[:key]
  end

  def session_id
    cookies[session_key] if session_key
  end

  def add_body_class(*klasses)
    @_body_class = (Array.wrap(@_body_class) + klasses).compact.uniq
  end

  def escape_body_class(klass)
    klass.to_s.gsub(/[\/_]/, '-')
  end

  def add_layout_body_class(*klasses)
    add_body_class klasses.flatten.map do |klass|
      "layout-#{escape_body_class @last_template}"
    end
  end

  def body_class
    add_body_class "controller-#{escape_body_class controller.controller_path}"

    if current_page.respond_to?(:custom_css_classes) && current_page.custom_css_classes.present?
      current_page.custom_css_classes.strip.split(/\s+/).each do |cust_class|
        add_body_class "cust-#{escape_body_class cust_class}"
      end
    end

    # rendered_templates comes from an ActionView::Rendering extension in an initializer
    tmpl = rendered_templates.first
    if tmpl.respond_to?(:variable_name)
      add_body_class "template-#{escape_body_class tmpl.variable_name}"
    end

    @_body_class
  end

  def current_page
    controller.current_page
  end

  def current_user_role
    @current_user_role ||= current_user.role
  end

  def user?
    @current_user_is_user ||= current_user_role.includes?('user')
  end

  def employee?
    @current_user_is_employee ||= current_user_role.includes?('employee')
  end

  def admin?
    @current_user_is_admin ||= current_user_role.includes?('administrator')
  end

  def superuser?
    @current_user_is_superuser ||= current_user_role.includes?('superuser')
  end

  def e9_user?
    @current_user_is_e9 ||= current_user_role.includes?('e9_user')
  end

  def logged_out?
    @logged_out ||= E9::Roles.logged_out_role?(current_user_role)
  end

  def actions_list_items
    @_actions_list_items ||= ''.html_safe
  end

  def clear_actions_list_items
    @_actions_list_items = nil
  end

  def add_actions_list_item(content = nil, &block)
    content = capture(&block) if block_given?
    actions_list_items.concat(content_tag(:li, content).html_safe) if content
  end
  
  def actions_list(opts = {})
    content = content_tag(:ul, actions_list_items)
    content = content_tag(:div, content, :class => 'action-links') if opts[:wrapper]
    clear_actions_list_items
    content
  end

  def title(*args)
    options = args.extract_options!

    # args not empty : assume title passed, build h1 unless hide_title is an option
    if !args.empty?
      @title = args

      options[:class] = [options[:class], 'title'].compact.join(' ')
      options[:class].concat(' error') if options[:error]

      options[:insert] = [options[:insert], spinner].join(' ').html_safe

      unless options[:hide_title]
        content = sanitize(_resolve_title_segment(args.first))
        content = content_tag(options[:inner_tag], content) if options[:inner_tag]

        content_tag(:h1, options.slice(:id, :class)) do
          ''.html_safe.tap do |html|
            html.concat options[:insert_before] if options[:insert_before]
            html.concat content
            html.concat options[:insert]        if options[:insert]
          end
        end
      end
    end
  end

  # makes use of @title if which is built by the title() helper
  def meta_title(title = nil, options = {})
    title ||= @title
    title = Array.wrap(title)

    title.map! {|t| _resolve_title_segment(t, :meta => true) }

    [title, E9::Config[:site_name]].flatten.compact.map {|t| sanitize(t) }.join(options[:delimiter] || ' - ').html_safe
  end

  def title_with_feed(*args)
    options = args.extract_options!
    url = options.delete(:url) || {}
    options[:insert_before] = link_to_feed(nil, url)
    @_content_for[:head] << auto_discovery_link_tag(:rss, url)
    title(*(args << options))
  end

  def link_to_feed(link_text = nil, url = nil, options = {})
    default_title = link_text || e9_t(:subscribe_link_text)

    # if nil, use current path?  This is more a failsafe than an option
    url ||= {}

    # url could be a string. if it is, leave it alone.
    if url.kind_of?(Hash)
      url.reverse_merge!(query_params.merge(:format => :rss, :only_path => false))
      url.except!(:page, :per_page)
    end

    klass = options[:class] || 'icon feed'

    options.reverse_merge!(:alt => default_title, :title => default_title, :class => klass)

    link_to(default_title, url, options)
  end

  def flash_messages(keys = [:alert, :notice])
    messages = keys.select {|key| flash[key] }.map do |key|
      content_tag(:div, flash[key].html_safe, :class => "flash #{key}")
    end

    flash.discard
      
    # NOTE it's important that the container be returned even if messages are blank
    <<-RETV.html_safe
      <div class="flash-messages">
        #{messages.join.html_safe if !messages.blank?}
      </div>
    RETV
  end

  def breadcrumbs_helper(options = {})
    render_breadcrumbs(options.reverse_merge(:builder => UListBuilder)).html_safe
  end

  ##
  # Rendering
  #

  #
  # render all a region's renderables
  #
  def render_region(domid, options = {})
    view = options[:view] || current_page

    if region = view.region(domid)
      locs = liquid_env.merge(:region => region)

      content_tag(:div, :id => "#{domid}-region", :class => 'renderable-region') do
        ''.html_safe.tap do |buffer|
          region.nodes(:include => :renderable).each do |node|
            render_renderable node.renderable, buffer, locs.merge(:node => node)
          end
        end
      end
    end
  end

  #
  # renders an individual renderable
  #
  # TODO Renderable should include enough View that it knows how to render itself and the decision is not made in a helper
  #
  def render_renderable(renderable, buffer = nil, locs = {})
    return '' unless renderable.present?

    buffer ||= ''.html_safe

    benchmark "Rendered #{renderable.cache_key}", :level => :warn, :silence => true do
      locs.merge!(:renderable => renderable)

      klass = renderable.class

      html = ''

      partial_path = klass.respond_to?(:partial_path) ? klass.partial_path : klass.model_name.partial_path
      html.concat render(:partial => partial_path, :object => renderable)

      element = klass.respond_to?(:element) ? klass.element : klass.model_name.element

      div_args = { :id => renderable.to_anchor, :class => "renderable #{element}" }

      if klass.renderable? && current_user.role.includes?(renderable.role)
        div_args[:"data-node"]             = node = locs[:node] && locs[:node].id
        div_args[:"data-renderable"]       = element
        div_args[:"data-renderable-name"]  = renderable.name

        div_args[:"data-update-node-path"] = edit_polymorphic_path([:admin, locs[:node]]) rescue nil

        # try a few argument setups for polymorphic routes
        path_arg_attempts = [

          # admin scoped, object class (the standard)
          [:admin, klass],

          # no scope, the object class
          [nil, klass]

          # no scope, the object base class (if individual subclass routes don't exist)
          #[nil, klass.base_class]
        ]

        begin
          scope, klass = path_arg_attempts.shift
          div_args[:"data-renderables-path"] = polymorphic_path([scope, klass])
          div_args[:"data-renderable-path"]  = edit_polymorphic_path([scope, renderable.becomes(klass)]).sub(/\/edit$/, '')
        rescue
          retry unless path_arg_attempts.empty?
        end
      end

      buffer << content_tag(:div, html.html_safe, div_args)
    end
  end

  def render_template(template, env, type)
    return '' if template.blank?

    case type.to_sym
    when :liquid
      Liquid::Template.registers[:view] = self
      Liquid::Template.parse(template).render!(env.merge(:template => self).stringify_keys).html_safe
    else 
      render(:text => template, :type => type)
    end
  end

  def render_liquid(template, env = {})
    render_template(template, env.reverse_merge(liquid_env), :liquid)
  end

  #
  # helper to pass the same hash of parameters to a collection, named thus because
  # rails provides no way to pass a layout to a collection in the same way you can
  # do, for example, render 'some/partial', :collection => @collection
  #
  def render_collection_with_layout(opts)
    c = opts.delete(:collection)
    c.collect {|obj| render opts.merge(:object => obj) }.join("\n").html_safe
  end

  
  ##
  # E9 Footer info
  #

  def footer_copyright_year
    config_year, this_year = E9::Config['copyright_start_year'].to_s, Date.today.year.to_s
    if config_year == this_year
      this_year
    else
      "%s - %s" % [config_year, this_year].sort
    end
  end

  def footer_copyright_content
    "&copy; #{footer_copyright_year} #{E9::Config['site_name']}".html_safe
  end

  def footer_tag_content
    link_to e9_t(:e9_link), 'http://e9digital.com', :rel => 'external', :title => e9_t(:e9_link), :id => 'e9_link'
  end

  def pagination_per_page
    controller.send(:pagination_per_page)
  end

  def link_to_link(link, opts = {})
    link = url_for(link) unless link.is_a?(String)
    link_to link, link, opts
  end

  def new_window_link_params
    {:class => 'new-window'}
  end

  def link_to_new_window(name, url, options = {})
    link_to name, url, options.merge(new_window_link_params)
  end

  def popup_link_params
    {:rel => 'popup'}
  end

  def link_to_popup(name, url, options = {})
    link_to name, url, options.merge(popup_link_params)
  end

  def resource_error_messages!(options = {})
    object = options[:resource] || resource

    if object.errors.empty? || ( (errors_on = options.delete(:on)) && (errors_on & object.errors.keys).empty? )
      return ''
    end

    errors = object.errors.map {|attribute, msg| msg }.flatten.map {|m| "<li>#{m}</li>"}.join("\n")

    <<-HTML.html_safe
      <div id="errorExplanation">
        <ul>#{errors}</ul>
      </div>
    HTML
  end

  def truncated_span(text, opts = {})
    truncated_content_tag(:span, text, opts)
  end

  # TODO I think content_tag might have over 3 args, check.
  def truncated_content_tag(element, text, opts = {})
    return '' if text.blank?

    length = opts.delete(:length) || 25
    opts.reverse_merge!(:title => text, :alt => :text)
    content_tag element, truncate(text, :length => length), opts
  end

  def linked_in_company_page_link
    url = E9::Config[:linked_in_company_page_url]

    if url.present?
      title = e9_t(:linked_in_link_title)
      link_to title, url, :rel => :external, :class => 'social-link linked-in', :title => title
    end
  end

  def facebook_company_page_link
    url = E9::Config[:facebook_company_page_url]

    if url.present?
      title = e9_t(:facebook_link_title)
      link_to title, url, :rel => :external, :class => 'social-link facebook', :title => title
    end
  end

  def twitter_company_page_link
    url = E9::Config[:twitter_company_page_url]

    if url.present?
      title = e9_t(:twitter_link_title)
      link_to title, url, :rel => :external, :class => 'social-link twitter', :title => title
    end
  end


  def date_select_options(options = {})
    date  = options.delete(:from_date) || Date.today
    cdate = Date.today

    sel_options = []

    if options[:type] == :until
      options[:prefix] ||= 'Before'
      options[:label]  ||= options[:prefix] + ' Now'
    elsif options[:type] == :in_month
      options[:prefix] ||= ''
      options[:label]  ||= 'Since Inception'
    else
      options[:prefix] ||= 'From'
      options[:label]  ||= options[:prefix] + ' Inception'
    end

    begin
      date_format = options[:date_format] || "%B 1, %Y"
      fmt = [options[:prefix], date_format].join(' ')
      sel_options << [date.strftime(fmt), date.strftime('%Y/%m')]
      date += 1.month
    end while date.month <= cdate.month || date.year < cdate.year

    sel_options.reverse!

    sel_options.shift if options[:skip_current]

    sel_options.unshift([options[:label], nil])

    options_for_select(sel_options)
  end

  def mailer_select_tag(*args)
    options = args.extract_options!
    emails = args.shift

    @email_id_counter ||= 0
    @email_id_counter += 1
    options.merge!(:id => "email_id_#{@email_id_counter}")

    emails = emails.active.all
    emails.sort_by! {|n| n.name.upcase }
    emails.map! {|n| [n.name, n.id] }
    emails.unshift ['Select an Email', nil]

    select_tag 'email_id', options_for_select(emails), options
  end

  private

    def _resolve_title_segment(arg, options = {})
      options[:meta] && arg.respond_to?(:meta_title) && arg.meta_title.presence ||
        arg.respond_to?(:title) && arg.title.presence ||
          arg.dup
    end

end
