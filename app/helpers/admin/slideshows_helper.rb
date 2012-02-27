module Admin::SlideshowsHelper
  def available_slides(for_slideshow = nil)
    @_available_slides ||= Slide.for_roleable(current_user).all
    for_slideshow ? @_available_slides - for_slideshow.slides : @_available_slides
  end

  def available_slide_select_options(for_slideshow = nil)
    options = available_slides(for_slideshow).
                sort_by {|slide| slide.title.downcase }.
                map {|slide| [slide.title, slide.id] }.
                unshift no_choice_select_option(Slide)

    options_for_select(options)
  end

  def add_slide_to_slideshow_select_tag(slideshow)
    select_tag :id, available_slide_select_options(slideshow), :id => "slide_id_select"
  end

  def no_choice_select_option(model)
    [e9_t(:no_choice_select_option, :element => model.model_name.human), nil]
  end

  def remove_slide_from_slideshow_link(slideshow, slide)
    link_to e9_t(:remove_link), remove_admin_slideshow_slide_path(slideshow, slide), { 
      :confirm => e9_t(:confirmation_question),
      :method  => :delete,
      :remote  => true
    }
  end

  def slide_layout_select_options()
    Layout.
      for_page_class(Slide).
      order("layouts.parent_id ASC, layouts.name ASC").
      map {|layout| [layout.name, layout.id] }.
      unshift [e9_t(:all_layouts), nil]
  end

  def slide_layout_scope_select
    select_tag(:of_layout, options_for_select(slide_layout_select_options, slide_layout_scope))
  end

end
