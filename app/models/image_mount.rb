class ImageMount < ActiveRecord::Base
  CATCHALL_FALLBACK_URL = '/images/defaults/upload_image_thumb.png'

  include Image::DimensionCaching
  self.dimension_target = :processed_image

  serialize :instructions, Hash

  #
  # Associations
  #

  belongs_to :spec, :polymorphic => true, :autosave => false, :inverse_of => :image_mounts
  belongs_to :owner, :polymorphic => true, :autosave => false

  belongs_to :image

  # an image (new or existing) should always be returned
  alias :_existing_image :image
  def image() _existing_image || build_image end

  alias :_build_image :build_image

  def build_image(args={})
    _build_image.tap do |img|
      img.image_tags = default_image_tags
    end
  end

  def default_image_tags
    if mounted_association.present?
      owner_name = owner.present? && owner.class.model_name.human || mounted_on
      ["#{owner_name} #{mounted_association}".titleize]
    else
      []
    end
  end

  #
  # Scopes
  #

  scope :attached, lambda { joins(:image).merge(Image.attached) }

  scope :unattached, lambda { 
    no_img         = arel_table[:image_id].eq(nil)
    img_unattached = Image.attached_condition(false)
    conditions     = no_img.or(img_unattached)

    includes(:image).where(conditions)
  }

  scope :ordered, lambda { order(:position) }

  #
  # Delegations
  #

  # NOTE width/height are cached on the record and handled in the DimensionCaching module
  delegate :aspect_ratio, :portrait?, :landscape?, :depth, :number_of_colours, :format, :image?, 
      :to => :processed_image, :allow_nil => true

  delegate :attachment, :attached?, :to => :image, :allow_nil => true

  delegate :file_ext, :file_desc, :persisted?, :to => :image, :prefix => true, :allow_nil => true


  # fallback to the fallback_url for our url
  def url() processed_image.try(:url) || fallback_url end

  #
  # ImageSpecification implementation
  #

  include E9::ImageSpecification

  def spec_width() _spec_dimension(read_attribute :spec_width) end
  def spec_height() _spec_dimension(read_attribute :spec_height) end

  def spec_name
    if spec != self && spec.respond_to?(:spec_name)
      spec.spec_name
    elsif mounted_association
      mounted_association.singularize.titleize
    else
      'Image'
    end
  end

  def _spec_dimension(dim)
    case dim
    when Numeric, /^\d+$/ then dim.to_i
    when String then E9::Config[dim]
    end
  end

  protected :_spec_dimension

  def should_crop?
    crop_dimensions.present?
  end

  def crop_dimensions
    spec.try(:spec_dimensions) || Dimensions.new(self, 0, 0)
  end

  #
  # Callbacks
  #

  # ImageMounts may be their own specs, in which case it's necessary to update
  # the spec_id with the newly assigned record id after creation
  after_create :update_self_spec_id, :if => 'self.spec == self'

  before_save :coerce_image_dimensions
  before_save :reset_versions, :if => 'image_id_changed?'

  #
  # Instance Methods
  #

  def processed_image
    # TODO memoize?
    image.process(instructions)
  end

  alias :local_spec :spec
  #
  # Get the associated spec if it exists, or try to find a floating spec based
  # on the mounted_as.
  #
  def spec
    # NOTE the idea here is that the local spec will be used if it exists, or
    # an image_spec lookup will happen based on mounted_as
    local_spec.presence || 

      spec_dimensions.present? && self ||
      
      @floating_spec ||= begin
        if mounted_as.present?
          # first we try to find the exact spec based on mounted record and mount 
          # name (e.g. user#avatar)
          ImageSpec.find_by_identifier(mounted_as) ||

            # If that fails we'll look for a more general spec based solely on
            # the mount association name (e.g. avatar)
            mounted_association && ImageSpec.find_by_identifier(mounted_association)
        end
    end
  end

  def mounted_on
    mounted_as && mounted_as.split('#')[0]
  end

  def mounted_association
    mounted_as && mounted_as.split('#')[1]
  end

  def mounted_as_options
    if mounted_association && klass = mounted_on.classify.constantize
      klass.mounted_as_options_for(mounted_association)
    end
  rescue NameError
  end

  #
  # Determine the fallback url for the image.
  #
  def fallback_url
    case retv = read_attribute(:fallback_url)

    # if in the format association#method it will try to call it, this is useful
    # for situations like a blog_post wanting the default url to be the user's
    # avatar
    when /^(spec|owner)#(.*)/
      if association = send($1)
        association.respond_to?($2) && association.send($2)
      end

    # when blank it'll try to get the url from the spec
    when /^\s*$/, nil
      spec != self && spec.try(:fallback_url) || CATCHALL_FALLBACK_URL

    # otherwise the assumption is that fallback_url is a hardcoded path
    else
      retv
    end.presence
  end

  def as_json(options={})
    {
      :id         => id,
      :width      => width,
      :height     => height,
      :url        => url,
      :attachment => image.as_json
    }
  end

  def reset
    self.image = parent.try(:image)
    self.instructions = nil
  end

  def reset!
    reset
    save(:validate => false) && reload
  end

  def versions
    if owner.present?
      owner.mounted_image_versions_for(mounted_association)
    else
      []
    end
  end

  def has_versions?
    versions.any?
  end

  def parent
    if owner.present?
      owner.mounted_image_parent_for(mounted_association)
    end
  end

  protected

    def should_cache_dimensions?
      !cached_dimensions? || image.nil? || self.instructions_changed? || self.image_id_changed? || image.should_cache_dimensions?
    end

    def reset_versions
      versions.each do |version|
        version.image = self.image
        version.instructions = nil
        version.save
      end
    end

    def coerce_image_dimensions
      if attachment.present? && should_crop? && dimensions != crop_dimensions
        self.instructions = {
          '0' => [:thumb, "#{crop_dimensions}#"]
        }
      end
    end

    def update_self_spec_id
      reload
      self.class.update_all({:spec_id => self.id}, self.class.primary_key => self.id) == 1
    end

end
