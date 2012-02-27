# lib/validators/reserved_slug_validator.rb
class ReservedSlugValidator < ActiveModel::EachValidator
  ReservedSlugs = Rails.application.routes.routes.map(&:path).map do |path| 
    path[/^\/([a-zA-Z0-9\-_]+)(\(|\/)?/, 1]
  end.compact.uniq.freeze

  def validate_each(record, attribute, value)
    if value.respond_to?(:to_slug) && ReservedSlugs.member?(value.to_slug)
      record.errors.add(attribute, :reserved, options)
    end
  end
end
