module Admin::WidgetsHelper
  def widget_context_options
    contexts = Tagging.contexts(:show_all => true).sort
    contexts.delete 'tags'
    contexts.delete E9Tags.escape_context("Users*")

    options_for_select(
      contexts.map {|t|
        [E9Tags.unescape_context(t).titleize, t]
      }.unshift(['Tags', 'tags']).unshift(['None', nil]),
      resource.options.context
    )
  end

  def widget_tag_select_options
    # get taggings for context, "tags" is default
    scope = Tagging.scoped.includes(:tag).order('tags.name')
    
    # get context tags if the resource has context
    scope = scope.where(:context => resource.options.context) if resource.options.context.present?

    # if the resource has tags, exclude them from the select
    scope = scope.excluding_tags(resource.options.tags) if resource.options.tags.present?

    tag_array = scope.map {|t| [t.tag.name, t.tag.name] }.uniq.unshift(['Add...', nil])

    options_for_select(tag_array)
  end

  def widget_sort_select_options
    options_for_select(
      [
        ['Default', nil],
        ['Alphabetical by Title', 'alpha'],
        ['Chronological by Publish Date', 'published'],
        ['Chronological by Updated Date', 'updated'],
        ['Popularity', 'top']
      ], 
      resource.options.sort
    )
  end

  def slideshow_widget_type_select
    ''.html_safe.tap do |html|
      html.concat label_tag('feed_type', 'Type')
      html.concat select_tag('feed_type', options_for_select([
        ['All Slides',   'ft-open',      :"data-value" => ".open-slideshow"],
        ['By Slideshow', 'ft-slideshow', :"data-value" => "#ft-slideshow"]
      ]))
    end
  end

  def slideshow_widget_transition_select_options
    %w(fade flash pulse slide fadeslide).map{|n| [n,n]}.unshift(['Default', nil])
  end

  def widget_specific_content_select
    _widget_select(:widget_content, ContentView.feedable.excluding(resource.contents), 'content_id')
  end

  def widget_blog_select
    _widget_select(:widget_blog, Blog.for_roleable(current_user).excluding(resource.blogs), 'blog_id')
  end

  def widget_forum_select
    _widget_select(:widget_forum, Forum.for_roleable(current_user).excluding(resource.forums), 'forum_id')
  end

  def widget_slideshow_select
    _widget_select(:widget_slideshow, Slideshow.for_roleable(current_user).excluding(resource.slideshows), 'slideshow_id')
  end

  def widget_feed_format_select_options
    options_for_select [nil, 'div', 'ol', 'ul'], resource.options.feed_format
  end

  def widget_select_option_text(record)
    e9_t(:link_select_option, :model => record.class.model_name.human, :title => record.title)
  end

  private

  def _widget_select(id, scope, datatype)
    select_tag(id, 
      options_for_select(
        scope.
          map {|rec| [widget_select_option_text(rec), rec.id ] }.
          sort_by {|text, id| text.split(':').map(&:downcase) }.
          unshift(['Select...', nil])
      ), 
      {
        :class => 'list', 
        :"data-type" => datatype, 
        :"data-field" => "[options][#{datatype}]", 
        :"data-iname" => resource_instance_name
      }
    )
  end
end
