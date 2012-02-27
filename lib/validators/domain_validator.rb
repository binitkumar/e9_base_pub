# lib/validators/domain_validator.rb
class DomainValidator < ActiveModel::EachValidator
  ValidDomain = /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/

  def validate_each(record, attribute, value)
    unless value =~ ValidDomain
      record.errors.add(attribute, :invalid, options)
    end
  end
end
