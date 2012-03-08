class Banner < Renderable
  CATCHALL_FALLBACK_URL = '/images/defaults/upload_image_thumb.png'

  include E9::ImageSpecification
  def spec_name() read_attribute(:spec_name).presence || name end
  def spec_width() width end
  def spec_height() height end

  before_validation :ensure_appropriate_defaults

  mounts_images :images, :spec => 'self'
  has_many :image_mounts, :as => :spec, :inverse_of => :spec, :autosave => false

  #
  # whole bunch of oddness here.  banners don't need dimensions at all if
  # they're restricted to one size by the config
  #
  validates :width,  :presence => true, :numericality => { :only_integer => true, :allow_blank => true }
  validates :height, :presence => true, :numericality => { :only_integer => true, :allow_blank => true }

  ##
  # The scope that this class should return for the select array of Renderables
  # for swapping nodes.  This is not a scope because in other cases, it may return
  # records outside the class
  #
  def self.node_options(node, opts = {})
    scoped
  end

  # we don't generate a template
  def template() false end

  def as_json(options={})
    {
      :id => id,
      :images => images.attached.as_json
    }
  end

  def fallback_url() file.presence || CATCHALL_FALLBACK_URL end
  def fallback_url=(url) self.file = url end

  protected

  def ensure_appropriate_defaults
    if self.region_types.empty?
      self.region_types = RegionType.attr_like(:identifier, 'banner', :matcher => '%s%%')
    end

    self.width  = E9::Config[:banner_width]
    self.height = E9::Config[:banner_height]
  end
end
