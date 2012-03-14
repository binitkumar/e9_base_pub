module MenusHelper
  
  def menu_link(menu, level = 0, opts = {})
    link_to menu_link_text(menu, level, opts), menu_link_href(menu), menu_link_opts(menu)
  end

  #
  # Link text for a menu (or just truncation if a string is passed)
  #
  def menu_link_text(menu, level = 0, opts = {})
    text = case menu
           when Menu
             menu.link_text
           when String
             menu
           else
             menu.try(:title)
           end

    # failsafe?
    text ||= ''

    if !false_value?(opts[:truncate]) && level == 1 or true_value?(opts[:truncate_all])
      len = opts[:truncate].to_i
      len = default_menu_truncation if len.zero?
      truncate text, :length => len
    else
      text
    end
  end

  def default_menu_truncation
    @_default_menu_truncation ||= 25 # E9::Config[:default_menu_truncation]
  end

  #
  # Link options for a menu
  #
  # rel   : external nofollow - if menu.external?
  # class : new-window        - if menu.new_window?
  #
  def menu_link_opts(menu)
    {}.tap do |opts|
      opts[:rel]   = 'external nofollow' if menu.external?
      opts[:class] = [opts[:class], 'new-window'].compact.join(' ').strip if menu.new_window?
    end
  end

  #
  # The href for a menu link
  #
  def menu_link_href(menu)
    url_for(menu.href)
  end

  def render_menu(menu, options = {})
    Rails.cache.fetch("#{menu.cache_key}/#{current_user.role}/#{options.hash}") do

      menu, children = menu.to_array

      html = if options[:display_root]
               render_submenu(menu, children, 0, options)
             elsif children.present?
               i = 0
               children.inject(''.html_safe) do |buffer, ch|
                 buffer << render_submenu(ch[0], ch[1], 0, options.merge(:css_class => "mi-#{i+=1}"))
               end
             end

      if html.present?
        options[:ul_wrapper] ? content_tag(:ul, html.html_safe, :class => 'menu') : html.html_safe
      end
    end
  end

  def render_submenu(submenu, children, level, options = {})
    return '' unless should_show_menu?(submenu)

    level += 1

    content_tag(:li, :class => options.delete(:css_class)) do
      ''.html_safe.tap do |buffer|
        buffer << menu_link(submenu, level, options)
      
        if options[:show_children].nil? ? submenu.show_children? : true_value?(options[:show_children])
          if !children.blank?
            buffer << content_tag(:ul, :class => 'submenu') do
              children.inject(''.html_safe) do |html, ch|
                html << render_submenu(ch[0], ch[1], level, options)
              end
            end
          elsif SoftLink === submenu && submenu.linkable
            buffer << render_linkable(submenu.linkable, level + 1, options)
          end
        end
      end
    end
  end

  def should_show_menu?(menu)
    if menu.logged_out_only?
      logged_out?
    else
      current_user_role.includes?(menu.role)
    end
  end

  def render_linkable(*args)
    linkable = args.shift

    list_or_scope = case linkable
      when Blog  then linkable.blog_posts.published.recent.includes(:author, :blog)
      when Forum then linkable.topics.recent.includes(:comments, :author, :forum)
      when Topic then topic.comments.recent.includes(:author, :commentable => :forum)
      when Faq   then nil
      when Page  then
        case linkable.identifier
        when Page::Identifiers::BLOG_INDEX  then BlogPost.for_role(current_user_or_public_role).published.recent.includes(:author, :blog)
        when Page::Identifiers::FORUM_INDEX then Forum.for_role(current_user_or_public_role).ordered
        when Page::Identifiers::FAQ         then nil
        end
    end

    render_linkable_list_in_menu(*args.unshift(list_or_scope))
  end

  #
  # Takes an AR scope or an array of Linkables and renders it as
  # a list of links under a menu.
  #
  # NOTE if passing a scope, scope necessary find options before passing
  # to this method, e.g. render_linkable_list_in_menu(forum.topics.where(:foo => 'bar'))
  #
  def render_linkable_list_in_menu(scope_or_array, level, options)
    return '' unless scope_or_array.respond_to?(:map)

    records = if scope_or_array.respond_to?(:limit)
      scope_or_array.limit(E9::Config[:menu_record_count])
    else
      scope_or_array[0, E9::Config[:menu_record_count]]
    end

    return '' if records.empty?

    records = records.map do |record|
      link_text = menu_link_text(record, level, options)
      content_tag :li, link_to(link_text, record.path)
    end

    content_tag(:ul, records.join.html_safe, :class => 'submenu')
  end

  #
  # method to determine if a menu is "active"
  # i.e. a menu under this menu fully matches the request path
  #
  def menu_active?(menu, descendants)
    # home links should never be "active"
    menu_link_href(menu) != '/' && [menu, descendants].flatten.compact.any? {|m| menu_current?(menu) }
  end

  #
  # method to determine if a menu is "current"
  # i.e. the exact url of the request
  #
  def menu_current?(menu)
    menu && path_is_current?(menu_link_href(menu))
  end

  def path_is_current?(path)
    path && path == request.path
  end

  def path_is_active?(path)
    path && request.path =~ Regexp.new(path)
  end

end
