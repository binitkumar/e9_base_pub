class AttachmentUploader < BaseUploader
  # this won't run if there are no specified_dimensions, making it ok
  # for non-image attachments
  process :resize_to_specified_dimensions!

  def extension_white_list
    model.is_a?(Image) ? %w(jpg jpeg gif png) : nil
  end

  version :thumb, :if => :should_create_thumbs? do
    Rails.logger.error("PROCESSING")
    process :resize_to_fill => [72, 72]
  end

  def name(*args)
    if model.is_a?(Image)
      label_name(*args)
    else
      file.try(:filename) || 'attachment'
    end
  end

  def extension
    File.extname(name)
  end

  # Description of file types acceptable for the uploader
  # (passed to uploadify)
  #
  def file_desc
    "Files (#{file_ext(',')})"
  end

  def default_url
    if model.is_a?(Image)
      model.default_url || File.join('/', DEFAULTS_BASE_PATH, 'upload_image_thumb.png')
    end
  end

  protected

    def should_create_thumbs?(file)
      model.should_create_thumbs? && (file.nil? || (file.path =~ /(jpe?g|png|gif|bmp)$/i).present?)
    end
end
