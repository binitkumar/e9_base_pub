require 'active_model/errors'

class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  DEFAULTS_BASE_PATH = 'images/defaults'

  class_inheritable_writer :specified_dimensions
  self.specified_dimensions = []


  class << self
    def model_name
      @_model_name ||= ActiveModel::Name.new(::Image)
    end

    include E9::ImageSpecification

    def width
      _specified_dimensions[0]
    end

    def height
      _specified_dimensions[1]
    end

    def _specified_dimensions
      dims = read_inheritable_attribute(:specified_dimensions)
      dims.respond_to?(:call) ? dims.call : dims
    end

    # NOTE BUG FIX
    def specified_dimensions?
      false
    end
  end

  def host
    respond_to?(:fog_host) && fog_host.presence || '/'
  end

  #
  # The specified dimensions lookup is slightly complex and works as follows:
  # 
  # primarily:
  #
  # If the mount is a primary image (not a version) and the model mounted responds to
  # specified_dimensions, accept that model's specified dimensions as overriding
  # any that may be set on the mount itself.
  #
  # otherwise:
  #
  # Look to the mount for specified dimensions, which are set as a class inheritable
  # attribute, such that versions (which are anonymous subclasses of the mount's class)
  # can override them inside their block.  Specified dimensions can be set in this way
  # as a static array, which is simply applied, or a proc, which is called at the time
  # of processing.
  #

  delegate :specified_dimensions, :specified_dimensions?, :satisifed_by?, :to => :specification, :allow_nil => true

  # TODO really need to refactor this whole business.
  def errors
    @errors ||= ActiveModel::Errors.new(::Image.new)
  end

  # TODO really need to refactor this whole business.
  def satisfies_specification?
    return true if specification.satisfied_by?(self)

    errors.add(:file, :image_spec, {
      :specification_name => specification_name, 
      :specified_dimensions => specified_dimensions
    })

    false
  end

  def specification_name
    @_specification_name ||= name
  end

  def specification
    @_specification ||= begin
      if version_name.present? || !model.respond_to?(:specified_dimensions)
        self.class
      else
        model
      end
    end
  end

  def height; _image.try(:[], 'height') || 0 end
  def width;  _image.try(:[], 'width')  || 0 end

  #
  # determine the uploader's name
  #
  # used in form labels, typically:
  #
  # a main image for a class would want to 
  #
  def name(options = {})
    # delegate to an image's associated model if we're mounted on image and it has one
    name_delegate = attachee || model

    _name = model.specification_name if mounted_on_attached_image?

    # otherwise sends it's version or mount name to the name_delegate to be humanized
    _name ||= name_delegate.class.human_attribute_name(version_name || mounted_as)

    # and prepends the name_delegate's class name if options[:class]
    _name = "#{name_delegate.class.model_name.human} #{_name}" if options[:class]

    _name
  end

  alias :label_name :name

  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  # A string of file extensions acceptable for the uploader.
  # (passed to uploadify)
  #
  def file_ext(delimiter= ';')
    (extension_white_list || []).map {|ext| "*.#{ext}" }.join(delimiter)
  end

  # Description of file types acceptable for the uploader
  # (passed to uploadify)
  #
  def file_desc
    "Images (#{file_ext(',')})"
  end

  # An "attached" image is one that is mounted on another model.
  # Image records that aren't attached are probably (thus far)
  # temporary; used for cropping, etc.
  #
  def mounted_on_attached_image?
    model.is_a?(Image) && model.owner.present?
  end

  # The record an image is attached to
  #
  def attachee
    model.owner if mounted_on_attached_image?
  end

  # Mounter column options for this uploader defined on the model
  #
  def options
    model.class.uploader_options[mounted_as]
  end

  def url(*args)
    retv = super

    # If not present this is the default_url, which we don't want
    # to cache based on the model.
    #
    # If updated_at is nil it means the model doesn't respond to
    # updated_at, and this uploader has no means of determining
    # updated_at time.
    if !present? || updated_at.nil?
      retv
    else
      "#{retv}?#{updated_at}"
    end
  end

  def updated_at
    if model.respond_to?(:updated_at)
      (model.updated_at || DateTime.now).to_i
    end
  end

  #
  # Resize to the specified_dimensions for the instance
  #
  def resize_to_specified_dimensions!
    return unless specified_dimensions?
    return if model.respond_to?(:skip_auto_resize?) && model.skip_auto_resize?

    Rails.logger.info "BaseUploader#resize_to_specified_dimensions! - Resizing to #{specified_dimensions.inspect}"

    width, height = specified_dimensions

    manipulate! do |img|
      cols, rows = img[:dimensions]
      img.combine_options do |cmd|
        if width != cols || height != rows
          scale = [width/cols.to_f, height/rows.to_f].max
          cols = (scale * (cols + 0.5)).round
          rows = (scale * (rows + 0.5)).round
          cmd.resize "#{cols}x#{rows}"
        end

        cmd.background "rgba(0, 0, 0, 0.0)"
        cmd.gravity 'Center'
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end
      img
    end
  end

  def scale!(factor)
    Rails.logger.info "BaseUploader#scale! - Scaling by factor of #{factor}"

    manipulate! do |img|
      img.scale "#{factor * 100}%"
      img
    end
  end

  def crop!(x, y, w, h)
    manipulate! do |img|
      cmd = ::MiniMagick::CommandBuilder.new('mogrify')

      cmd.crop "#{w}x#{h}+#{x}+#{y}" # crop at the given coords
      cmd << "+repage"               # +repage to solve gif issues
      cmd.quality '92'               # because imagemagick sets quality in collapse! ?
      cmd << "#{img.path}[0]"        # set the frame to 0 (to flatten) stolen from collapse!

      Rails.logger.info "BaseUploader#crop! - Running MiniMagick Command [#{cmd.command}]"

      img.run(cmd)
      img
    end
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  private

  # TODO should really cache this, but need to implement all the places to
  # clear the cached data (after resize, etc)
  def _image
    # NOTE this will raise by itself if fog is not in the bundle (it's not required for file storage)
    raise unless self.class.storage == CarrierWave::Storage::Fog

    # try to read from the url?
    ::MiniMagick::Image.read(read)
  rescue
    ::MiniMagick::Image.open(current_path) rescue nil
  end
end
