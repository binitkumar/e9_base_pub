class DealDecorator < BaseDecorator
  decorates :deal

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]   = model.id
      hash[:type] = model.class.name
      hash[:name] = model.name
      hash[:url]  = model.url
    end
  end
end
