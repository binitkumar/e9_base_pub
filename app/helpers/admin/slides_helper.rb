module Admin::SlidesHelper
  def default_slide_layout_scope
    controller.send(:default_layout_scope)
  end

  def slide_layout_scope
    controller.send(:layout_scope)
  end

  def slide_layout_name
    controller.send(:layout_name)
  end

end
