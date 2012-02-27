class SlideshowWidget < Renderable
  include Renderable::Widget
  self.tag_name = 'slideshow'
  self.options_parameters |= [
    :autoplay, 
    :carousel,
    :carousel_follow, 
    :carousel_speed, 
    :carousel_steps,
    :clicknext,
    :height, 
    :pause_on_interaction, 
    :popup_links, 
    :show_counter,
    :show_info, 
    :transition, 
    :transition_initial,
    :transition_speed, 
    :width
  ]

  # Slideshows can't use templates currently, and would have to rewrite compile 
  # if they did, anyway.  So for now, just return nil for widget_template always.
  def widget_template
    nil
  end
end
