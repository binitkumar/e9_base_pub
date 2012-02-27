module ContentViewsHelper
  def content_header_link(content, options = {})
    content_tag(:h3, :class => [options[:class], 'header title'].compact.join(' ')) do
      link_to sanitize(content.title), content.url
    end
  end

  def content_thumb(content, options = {})
    content_tag(:div, :class => [options[:class], 'thumb'].compact.join(' ')) do
      link_to_if(
        options[:link_to].present?, 
        image_mount_tag(content.thumb, options[:image_options] || {}),
        options[:link_to]
      )
    end
  end

  def content_avatar(content, options = {})
    options.merge!(:class => 'avatar')

    # if the thumb is custom, continue and pass it to content_thumb
    unless content.thumb.present?
      options[:image_options] ||= {}

      # otherwise fall back to author, and if we're not supposed to display
      # the author info, fall back to the default avatar by sending a
      # new user with an anonymous name defined in i18n
      if content.display_author_info?
        content = content.author
        options[:image_options][:alt] = e9_t(:avatar_link_alt, :username => content.username)
      else
        content = User.new(:username => e9_t(:anonymous_username))
        options[:image_options][:alt] = e9_t(:default_avatar_link_alt)
      end
    end

    content_thumb(content, options)
  end

  def content_action_links(content, options = {})
    render 'shared/action_links', options.merge(:content => content)
  end

  def content_dateline(content, options = {})
    if content.display_date? && content.published?
      content_tag :div, localize(content.published_at, :format => :dateline), :class => 'dateline'
    end
  end

  def content_labels_with_context(content, options = {})
    if !content.respond_to?(:display_labels) || content.display_labels?
      if content.respond_to?(:has_tags?) && content.has_tags?
        render 'e9_tags/tag_list_with_context', options.merge(:taggable => content)
      end
    end
  end

  def content_labels(content, options = {})
    content_labels_with_context(content, options)
  end

  def content_body(content, options = {})
    content_tag :div, render_liquid(content.body, options[:locals] || {}), :class => 'content-body'
  end

  def content_byline(content, options = {})
    if content.display_author_info?
      content_tag(:div, :class => 'byline') do
        e9_t :byline, 
             :email    => content.author.try(:email) || e9_t(:no_author_name),
             :username => content.author.try(:username) || e9_t(:no_author_name),
             :name     => content.author.try(:name) || e9_t(:no_author_name)
      end
    end
  end

  def content_created_byline(content, options = {})
    if content.display_author_info?
      content_tag(:div, :class => 'created-byline') do
        e9_t :created_byline, 
             :at       => localize(content.created_at, :format => :dateline),
             :email    => content.author.try(:email) || e9_t(:no_author_name),
             :username => content.author.try(:username) || e9_t(:no_author_name), 
             :name     => content.author.try(:name) || e9_t(:no_author_name)
      end.html_safe
    end
  end

  def content_comments(content, options = {})
    if content.allow_comments?
      render 'comments/comments', :commentable => content
    end
  end

  def author_info(content)
    ActiveSupport::Deprecation.warn 'author_info deprecated: replace with created_byline, etc'
    content_created_byline(content)
  end

  def link_html(record)
    link_to record.link_text.presence || record.title, record.url
  end

  def permalink(record)
    record.url
  end

  def share_link(page)
    link_to e9_t(:share_link, :scope => :pages), page_url(page)
  end

  def page_comments_link(page)
    link_to e9_t(:comments_link, 
                 :scope => :pages,
                 :comments_count => page.comments.count), 
                 page_url(page, :anchor => :comments)
  end

end
