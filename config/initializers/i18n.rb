require 'i18n'

module I18n
  #
  # rather ugly hack to handle #localize calls with nil, which
  # would normally raise an exception
  #
  # NOTE localize doesn't use the same exception mechanism as
  # translate and transliterate, which is redefined below
  #
  class << self
    alias :localize_without_rescue :localize

    def localize(*args)
      localize_without_rescue(*args)
    rescue => e
      Rails.logger.error(e)
      ''
    end

    alias :l :localize
  end
end

#
#
I18n.exception_handler = Class.new do
  def call(exception, locale, key, options)
    if Rails.env.production?
      #
      # Fallback.  Might look odd but it's better than a
      # translation error in production
      #
      key.to_s.split('.').last.capitalize

    elsif exception.is_a?(I18n::MissingTranslationData)
      #
      # I18n v0.4 doesn't include html_message
      #
      exception.message

    else
      raise exception
    end
  end
end.new
