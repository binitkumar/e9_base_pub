class ImageSpecSatisfactionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && !value.present?

    unless options[:ignore_spec]
      images = Array.wrap(value)

      images.delete_if {|i| !i.file? } if options[:ignore_unattached]

      passed, failed = images.partition {|image| image.satisfies_specification? }

      return if failed.empty?

      if record.respond_to?(:specified_dimensions)
        record.errors.add(attribute, :invalid, options.merge({
          :value      => value, 
          :count      => failed.length > 1 ? "#{failed.length} images are" : "1 image is",
          :dimensions => failed.first.specified_dimensions
        }))
      else
        failed.each do |failure|
          failure.errors[:file].each do |error|
            record.errors.add(attribute, error)
          end
        end
      end
    end
  end
end
