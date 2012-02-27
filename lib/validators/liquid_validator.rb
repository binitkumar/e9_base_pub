# lib/validators/liquid_validator.rb
class LiquidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      Liquid::Template.parse(value)
    rescue => e
      #record.errors.add(attribute, :template, :message => e.message)
      record.errors.add(attribute, e.message)
    end
  end
end
