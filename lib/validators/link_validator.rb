class LinkValidator < ActiveModel::EachValidator
  ValidLink = /^(https?:\/\/|\/)/
  ValidLinkExternalOnly = /^https?:\/\//

  def validate_each(record, attribute, value)
    regex = options[:external_only] ? ValidLinkExternalOnly : ValidLink
    unless options[:allow_blank] && value.blank? || value =~ regex
      record.errors.add(attribute, :invalid, options)
    end
  end
end
