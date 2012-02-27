require 'chronic'

# Slightly misnamed, this validates a "date" with the requirement that it is
# parseable by Chronic.  This meansthe value could be any number of strings that
# can parse to a Date or DateTime, but aren't typical "dates"; e.g. "tomorrow",
# "5 hours from now", etc.  See Chronic documentation for details.
#
# What this means is that this validator will pass strings that aren't considered
# dates by Rails, which will subsequently be thrown away on database conversion.
#
# This typically the value you want to validate via this validator should already
# be converted to Date, DateTime, etc.
#
class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? && options[:allow_blank]
      value = case value
              when Time, DateTime; value
              else Chronic.parse(value) rescue nil
              end

      if !value.respond_to?(:acts_like_time?) || !value.acts_like_time?
        record.errors.add(attribute, :invalid, options)
      elsif options[:future] && value <= DateTime.now
        record.errors.add(attribute, :not_future, options)
      end
    end
  end
end
