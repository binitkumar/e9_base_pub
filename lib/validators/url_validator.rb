# lib/validators/url_validator.rb
class UrlValidator < ActiveModel::EachValidator
  ValidUrl = /(^(https?:\/\/)?\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i

  def validate_each(record, attribute, value)
    unless value =~ ValidUrl
      record.errors.add(attribute, :invalid, options)
    end
  end
end
