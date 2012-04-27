class CategoryDecorator < BaseDecorator
  def as_json(options = {})
    super.tap do |hash|
      hash[:title] = model.title
      hash[:type]  = model.class.model_name.underscore
      hash[:url]   = model.url

      if model.respond_to?(:layout)
        hash[:layout] = model.layout && File.basename(model.layout.template.to_s, '.*')
      end
    end
  end
end
