class AttachmentUploader < BaseUploader
  HasImageExtension = /(jp?g|png|gif|bmp)$/i

  # this won't run if there are no specified_dimensions, making it ok
  # for non-image attachments
  process :resize_to_specified_dimensions!

  version :thumb, :if => :should_create_thumbs? do
    process :resize_to_fill => [72, 72]
  end

  def name(*args)
    file.try(:filename) || 'Attachment'
  end

  def extension_white_list
    nil
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

  protected

  # NOTE I don't remember why this is "true" for nil files
  def should_create_thumbs?(file)
    file.nil? || !!HasImageExtension.match(file.path)
  end
end
