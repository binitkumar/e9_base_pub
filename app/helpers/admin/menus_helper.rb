module Admin::MenusHelper

  ##
  # Menu form elements
  #
  def root_menu_select(current_menu)
    menus = menus_editable_by_current_user.map {|m| [Page.sanitize_and_strip(m.name), m.id] }
    select_tag :menu_id, options_for_select(menus, current_menu.try(:id))
  end

  def parent_menu_select_options(menu = nil, options = {})
    root_menu = menu ? menu.parent.try(:root) : nil

    nested_set_options(menus_editable_by_current_user(root_menu)) do |m| 
      next if m == menu # this should be covered but it isn't?
      next if options[:hide_leaves] && m.leaf? && !m.root?

      retv = menu_link_text(m).html_safe

      if !m.root?
        retv = "&nbsp;#{'>' * m.depth} #{retv}".html_safe
      end

      retv
    end.select {|str, id| str.present? }
  end

  def menus_editable_by_current_user(root_menu = nil)
    ( root_menu ? Menu.where(:id => root_menu.id) : Menu.roots ).editable_for_user(current_user)
  end


  ##
  # Menu#link form elements
  #
  
  def links_for_current_user
    @links_for_current_user ||= Link.for_roleable(current_user).menu_linkable.all
  end

  def link_select_option_text(link)
    e9_t(:link_select_option, :model => link.linkable.class.model_name.human, :title => Page.sanitize_and_strip(link.title))
  end

  def links_for_current_user_and_menu(menu)
    used_links = menu.parent ? menu.parent.links_in_hierarchy : []
    (links_for_current_user - used_links).unshift(menu.link).compact
  end

  def campaign_link_select_options
    link_select_options Link.for_role('guest').menu_linkable.all
  end

  def link_select_options(links_or_menu)
    menu, links = if links_or_menu.kind_of?(Menu)
      [links_or_menu, links_for_current_user_and_menu(links_or_menu)]
    else
      [nil, links_or_menu]
    end

    links.map {|l| [link_select_option_text(l), l.id] }.
      sort_by {|text, id| text.split(':').map(&:downcase) }.
      unshift([e9_t(:no_choice_select_option, :element => Link.model_name.human), nil])
  end

  ##
  # Text and links
  #
  def menu_name_with_depth(menu, depth)
    buf = ''
    buf << ('> ' * depth)
    buf << menu.link_text
    buf.html_safe
  end

  def menu_window_text(menu)
    menu.new_window? ? e9_t(:new_window) : e9_t(:same_window)
  end 

  def menu_login_text(menu)
    menu.logged_out_only ? 'no' : 'yes'
  end

  def menu_role_text(menu)
    ActiveRecord::Base.human_attribute_name(menu.role)
  end

  alias :role_text :menu_role_text

  def remove_icon_link(icon_attribute, text = 'Remove')
    content_tag(:a, text, :class => 'cache-remover', :rel => 'nofollow action')
  end
end
