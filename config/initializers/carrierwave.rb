require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'e9_base'

CarrierWave.configure do |config|
  config.storage = :file

  if Rails.env.development?
    config.enable_processing = true
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.validate_integrity = true
    config.validate_processing = true
  end

  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => E9::AWS.config[:access_key_id],
    :aws_secret_access_key  => E9::AWS.config[:secret_access_key],
    :region                 => E9::AWS.config[:region]
  }
end


unless Rails.env.development?

  require 'carrierwave/storage/fog'

  class CarrierWave::Storage::Fog::File
    # Rescues if delete is called on a file in the cloud that no longer exists
    def delete
      file.destroy rescue nil
    end

    # For consistency with file based uploader
    def filename
      path && File.basename(path)
    end
  end

  #
  # Excon throws a 404 exception which is never caught if the file doesn't exist
  # in the cloud.  Not sure how to properly handle this, but I think it's safe
  # to say that breaking the whole app is not the answer.
  #
  # This module simply rescues from super and returns the default_url specified
  # on the class (or nil if there isn't one).
  #
  module ExconUrlRescue
    def url(*args)
      super rescue default_url
    end

    alias :to_s :url
  end

  CarrierWave::Uploader::Base.send(:include, ExconUrlRescue)
end

ActiveRecord::Base.send(:extend, E9::Carrierwave::Model)
ActionController::Base.send(:include, E9::Carrierwave::Controller)
