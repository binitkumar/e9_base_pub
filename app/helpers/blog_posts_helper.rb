module BlogPostsHelper
  def blog_post_permalink(*args)
    opts = args.extract_options!
    args.compact!
    args.unshift(args.last.blog) if args.length == 1
    opts[:only_path] ? blog_blog_post_path(*args) : blog_blog_post_url(*args)
  end

  # NOTE page break must match the one passed to tinymce in admin.js
  PAGE_BREAK = "<!-- PAGE_BREAK -->"

  def listed_blog_post_body(blog_post)
    body = render_liquid(blog_post.body, :page => blog_post)

    permitted = current_user_role.includes?(blog_post.role)

    if (blog_view_is_digest? || !permitted) && (ind = blog_post.body.index(PAGE_BREAK))
      body = content_tag(:div, body[0...ind], :class => 'blog-post-teaser')
      body.concat link_to(permitted ? e9_t(:read_more_link) : e9_t(:sign_in_to_read_more_link), blog_post_permalink(blog_post), :class => 'read-more')
    end

    content_tag(:div, body.html_safe, :class => 'content-body')
  end

  def listed_record_body(record)
    body = render_liquid(record.body, :page => record)

    permitted = current_user_role.includes?(record.role)

    if ind = record.body.index(PAGE_BREAK)
      body = content_tag(:div, body[0...ind], :class => 'teaser')
      body.concat link_to(permitted ? e9_t(:read_more_link) : e9_t(:sign_in_to_read_more_link), record.path, :class => 'read-more')
    end

    content_tag(:div, body.html_safe, :class => 'content-body')
  end

  def blog_view
    @_blog_view ||= E9::Config[:blog_view]
  end

  def blog_teaser_body_length
    @_blog_teaser_body_length ||= E9::Config[:blog_teaser_body_length]
  end

  def blog_view_is_digest?
    blog_view == 'digest'
  end

  def blog_view_is_normal?
    blog_view == 'normal'
  end

  def paginated_menu_per_page
    E9::Config[:blog_pagination_records]
  end

  def all_blogs_link
    link_to blog_title, blogs_path, :class => 'blogs-link'
  end

  def blog_title
    @_blog_title ||= (Page.blog_index.try(:title) || 'Blog').html_safe
  end

  def archive_blog_subnav
    blog_subnav('archive')
  end

  def paginated_blog_subnav
    blog_subnav('pagination')
  end

  def blog_subnav(menu_type = nil)
    menu_type = E9::Config[:blog_submenu] unless Settings::BLOG_SUBMENU_VIEWS.member?(menu_type)

    current_blog = @blog || current_page.try(:blog) rescue nil

    # TODO abstract this behavior somehow "current_user's actual roles unless user is a guest, then 'user' roles"
    roled_blogs = Blog.for_role(current_user_or_public_role)
    blogs = roled_blogs.posted_on.ordered

    content_tag(:div, :id => 'blog-menu', :class => menu_type == 'pagination' ? 'paginated' : menu_type) do
      if roled_blogs.count > 1
        lis = content_tag(:li) do
          ''.html_safe.tap do |html|
            html << all_blogs_link
            html << content_tag(:ul) do
              ''.html_safe.tap do |inner_html|
                blogs.each do |blog| 
                  inner_html.concat blog_subnav_blog(menu_type, blog, blog == current_blog)
                end
              end
            end
          end
        end
      elsif blog = blogs.first
        lis = blog_subnav_blog(menu_type, blog, blog == current_blog)
      end

      content_tag(:ul, lis, :class => :menu)
    end
  end

  def blog_subnav_blog(menu_type, blog, expand = true)

    # NOTE Pagination happens at this initial stage because on BlogPost#show, the subnav "page" is determined for the
    #      resource.  In this way, the paginated subnav can open on the correct page for the currently viewed blog post
    blog_title = blog.title
    blog_href  = blog_path(blog)

    options = {}
    case menu_type
    when 'pagination'
      options.merge!(:page  => paging_page, :per_page => paginated_menu_per_page)
    when 'archive'
      options.merge!(:year => default_blog_post_year, :month => default_blog_post_month)
    end

    content_tag(:li, :id => "blog#{blog.try(:id)}_menu_li") do
      link_to(blog_title, blog_href).tap do |html|
        html.concat blog_subnav_blog_posts(menu_type, blog, @blog_posts, options) if expand
      end
    end
  end

  def default_blog_post_year
    @controller.send(:default_year)
  end

  def default_blog_post_month
    @controller.send(:default_month)
  end
  
  def blog_subnav_blog_posts(menu_type, blog, collection, options = {})
    route = lambda {|*args| blog_path(blog, *args) }

    if menu_type == 'pagination'
      page      = (options[:page]     || 1).to_i
      per_page  = (options[:per_page] || paginated_menu_per_page).to_i

      show_prev = page > 1
      show_next = page * per_page < collection.total_entries

      prev_link = if show_prev
                    link_to(e9_t(:previous_page_link), route.call(:page => page - 1, :per_page => per_page), :remote => true)
                  else
                    content_tag :span, e9_t(:previous_page_link)
                  end

      next_link = if show_next
                    link_to(e9_t(:next_page_link), route.call(:page => page + 1, :per_page => per_page), :remote => true)
                  else
                    content_tag :span, e9_t(:next_page_link)
                  end

      curr_link = nil

    elsif menu_type == 'archive'
      per_page  = collection.length

      year     = options[:year]  || DateTime.now.year
      month    = options[:month] || DateTime.now.month

      prev_post = blog.blog_posts.published_before_month_in_year(month, year).order_by_published_at(:desc).limit(1).first
      next_post = blog.blog_posts.published_after_month_in_year(month, year).order_by_published_at(:asc).limit(1).first

      prev_month = prev_post ? prev_post.published_at.month : nil
      prev_year  = prev_post ? prev_post.published_at.year  : nil
      next_month = next_post ? next_post.published_at.month : nil
      next_year  = next_post ? next_post.published_at.year  : nil

      # NOTE the next chronological post is the previous link and vice versa
      next_link = prev_post ? link_to(blog_month_submenu_link(prev_month, prev_year), route.call(:month => prev_month, :year => prev_year), :remote => true) : nil
      prev_link = next_post ? link_to(blog_month_submenu_link(next_month, next_year), route.call(:month => next_month, :year => next_year), :remote => true) : nil

      # never linking right now... 
      curr_link = link_to_unless(true, blog_month_submenu_label(month, year), route.call(:month => month, :year => year), :remote => true)
    end

    content_tag(:ul, :class => :submenu) do
      ''.html_safe.tap do |html|
        #html.concat content_tag(:li, prev_link, :class => 'blog-pagination') if prev_link
        html.concat content_tag(:li, curr_link) if curr_link

        per_page.times do |i|
          blog_post = collection[i]
          href      = blog_post ? blog_post_permalink(blog, blog_post, :only_path => true) : nil
          html.concat content_tag(:li, blog_post ? link_to(blog_post.title, href) : '')
        end

        #html.concat content_tag(:li, next_link, :class => 'blog-pagination') if next_link
      end
    end
  end

  def blog_month_submenu_label(month, year)
    "#{month_name_by_index(month)} #{year}"
  end

  def blog_month_submenu_link(month, year)
    "#{month_name_by_index(month)} #{year}"
  end

  # TODO i18n
  def month_name_by_index(n)
    n ? DateTime::MONTHNAMES[n.to_i] : ''
  end

  LINK_TEXT_WITH_COUNT_FORMAT_STRING = '%s <span class="count">(%s)</span>'.freeze
  def link_text_with_count(*args)
    LINK_TEXT_WITH_COUNT_FORMAT_STRING % args
  end

end
