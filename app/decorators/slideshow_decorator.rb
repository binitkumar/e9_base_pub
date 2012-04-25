class SlideshowDecorator < CategoryDecorator
  decorates :slideshow

  def as_json(options = {})
    super.tap do |hash|
      hash[:slides] = model.slides
      hash[:layout] = hash[:layout] || 'slideshow'
    end
  end
end
