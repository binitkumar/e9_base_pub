module Admin::FeedWidgetsHelper
  def feed_widget_display_checkbox(value)
    checked = resource.options.hide.respond_to?(:member?) && resource.options.hide.member?(value)

    ''.html_safe.tap do |html|
      html.concat label_tag("#{resource_instance_name}_options_hide_#{value}", 'Hide?')
      html.concat check_box_tag("#{resource_instance_name}[options][hide][]", value, checked, :id => "feed_widget_options_hide_#{value}", :class => "hide-widget-element")
    end
  end

  def feed_widget_feed_type_select
    select_tag('feed_type', options_for_select([
      ['None', nil],
      [e9_t(:mixed_content),       'ft-mixed',     :"data-value" => "#ft-mixed"],
      [e9_t(:specific_content),    'ft-specific',  :"data-value" => "#ft-specific"],
      [Blog.model_name.human,      'ft-blog',      :"data-value" => "#ft-blog"],
      [Event.model_name.human,     'ft-event',     :"data-value" => "#ft-event"],
      [Forum.model_name.human,     'ft-forum',     :"data-value" => "#ft-forum"],
      [Slideshow.model_name.human, 'ft-slideshow', :"data-value" => "#ft-slideshow"]
    ]))
  end

  def feed_widget_content_type_check_box(klass=nil)
    element, label_name = if klass
      [klass.model_name.element, klass.model_name.human]
    else
      ['all', e9_t(:all)]
    end

    field_id = "#{resource_instance_name}_options_content_type_#{element}"

    content_tag(:div, :class => 'field checkbox') do
      check_box_tag(
        "#{resource_instance_name}[options][content_type][]", 
        element, 
        resource.options.content_type.try(:member?, element),
        :id => field_id
      ).concat(
        label_tag(field_id, label_name)
      )
    end
  end
end
