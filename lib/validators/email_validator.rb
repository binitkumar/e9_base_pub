# lib/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  #LocalPartSpecialChars = Regexp.escape('!#$%&\'*-/=?+-^_`{|}~')
  #LocalPartUnquoted = '(([[:alnum:]' + LocalPartSpecialChars + ']+[\.\+]+))*[[:alnum:]' + LocalPartSpecialChars + '+]+'
  #LocalPartQuoted = '\"(([[:alnum:]' + LocalPartSpecialChars + '\.\+]*|(\\\\[\x00-\xFF]))*)\"'
  #Regex = Regexp.new('^((' + LocalPartUnquoted + ')|(' + LocalPartQuoted + ')+)@(((\w+\-+)|(\w+\.))*\w{1,63}\.[a-z]{2,6}$)', Regexp::EXTENDED | Regexp::IGNORECASE)

  # this is from an activemodel validator.  Doesn't blow up 1.9.2
  RailsEmailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def validate_each(record, attribute, value)
    unless value.blank? && options[:allow_blank]
      unless value =~ RailsEmailRegex
        record.errors.add(attribute, :invalid, options)
      end
    end
  end
end
