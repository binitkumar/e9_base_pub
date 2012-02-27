class ImageSpec < Renderable
  include E9::ImageSpecification
  def spec_name() read_attribute(:spec_name).presence || name end
  def spec_width() width end
  def spec_height() height end

  class << self
    def renderable?() false end
  end

  has_many :image_mounts, :as => :spec, :inverse_of => :spec, :autosave => false
  belongs_to :owner, :polymorphic => true

  def template() false end

  def fallback_url() file end
  def fallback_url=(url) self.file = url end

  def required?
    fallback_url.blank?
  end
end
