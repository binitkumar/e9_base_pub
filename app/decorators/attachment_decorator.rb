class AttachmentDecorator < BaseDecorator
  decorates :attachment

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]        = model.id
      hash[:type]      = model.class.name
      hash[:name]      = model.file_name
      hash[:url]       = model.file_url
      hash[:thumb]     = model.has_thumb? ? model.thumb.url : nil
      hash[:file_type] = model.file_type
    end
  end
end
