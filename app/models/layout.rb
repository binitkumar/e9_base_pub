class Layout < ActiveRecord::Base
  include E9::Roles::Roleable
  include E9::ActiveRecord::AttributeSearchable
  include E9::DestroyRestricted::Model
  include E9::Models::View

  after_save :assign_identifier, :on => :create
  before_destroy :ensure_not_system

  scope :for_page_class, lambda {|klass|
    attr_like(:identifier, klass.model_name.element, :matcher => "%s%%")
  }

  class << self
    def default_for_page_class(klass)
      base_klass = klass.base_class
      found_layout = nil
      begin
        found_layout = for_page_class(klass).first
      end while !found_layout and (klass = klass.superclass) != base_klass

      found_layout
    end

    alias :for :default_for_page_class
  end

  belongs_to :parent, :class_name => 'Layout', :foreign_key => :parent_id
  def parent_identifier; parent.try(:identifier) || identifier end

  has_one :image_spec, :as => :owner, :dependent => :destroy

  validates :template, :presence => true

  has_and_belongs_to_many :region_types

  has_many :pages, :dependent => :restrict

  RenderableFinderSql = 
    'SELECT renderables.* FROM renderables INNER JOIN nodes ' +
    'ON renderables.id = nodes.renderable_id INNER JOIN regions ' +
    'ON regions.id = nodes.region_id WHERE (regions.id IN (#{region_ids.join(\',\')})) ' +
    'AND renderables.type = \'__TYPE__\''

  has_many :placeholders, :readonly => true, :finder_sql => RenderableFinderSql.sub(/__TYPE__/, 'PlaceHolder')
  has_many :image_specs,  :readonly => true, :finder_sql => RenderableFinderSql.sub(/__TYPE__/, 'ImageSpec')
  has_many :snippets,     :readonly => true, :finder_sql => RenderableFinderSql.sub(/__TYPE__/, 'Snippet')
  has_many :partials,     :readonly => true, :finder_sql => RenderableFinderSql.sub(/__TYPE__/, 'Partial')
  has_many :banners,      :readonly => true, :finder_sql => RenderableFinderSql.sub(/__TYPE__/, 'Banner')


  #
  # Prototype a view from this layout.
  #
  # #prototype(ViewClass, initialization_options)
  #
  def prototype(*args)
    opts  = args.extract_options!
    klass = args.shift || Layout

    if klass == Layout
      opts[:parent]       ||= self.parent || self
      opts[:image_spec]   ||= self.image_spec.try(:clone)
      opts[:name]         ||= generate_copy_of_field(:name)
      opts[:template]     ||= template
      opts[:region_types] ||= region_types
    else
      opts[:layout]       ||= self
    end

    opts[:regions] ||= regions.map(&:copy)

    klass.new(opts).tap do |object|
      if klass.reflect_on_association(:images)
        object.images = image_specs.map do |image_spec|
          image_spec.image_mounts.build(:owner => object)
        end
      end

      if klass.reflect_on_association(:placements)
        object.placements = placeholders.map do |ph| 
          ph.placements.build(:owner => object)
        end
      end
    end
  end

  def prototype!(*args)
    prototype(*args).tap do |p|
      p.save!
    end
  end

  def reset!
    raise "Cannot reset or init a layout until it has been saved" if new_record? 
    regions.destroy_all
    region_types.each do |rt|
      regions.build.tap do |region|
        region.name        = rt.name
        region.domid       = rt.domid
        region.region_type = rt
      end
    end

    save!
    reload
    self
  end

  alias :init! :reset!

  ##
  # Method that Uploaders look to for the default image name of this Layout.
  # Pay attention to how this method works when creating Layouts in seeds.
  #
  # Rules:
  #
  # If there is no parent, it simply returns identifier.
  #
  # If there is a parent and the identifier does not match the expected format
  # of an auto-generated layout's identifier ("#{parent.identifier}_#{id}") then
  # once again, return identifier.
  #
  # If there is a parent, and identifier ends with a /_\d+$/ it's assumed that this
  # is a prototyped (auto-generated) Layout of the parent, and returns the parent's
  # identifier.
  #
  # So basically, when seeding layouts, id them as "#{parent.identifier}_#{some_unique_name}"
  # if you want to control their image path. E.g. if your Layout is a sub-layout of
  # "user_page" and concerns "testimonials", set identifier to be "user_page_testimonial",
  # and the system will look for /images/defaults/.../user_page_testimonial.png as the
  # default layout images.
  #
  def default_image_name
    parent && identifier =~ /_\d+$/ ? parent.identifier : identifier
  end

  protected

    def ensure_not_system
      raise Authorization::NotAuthorized.new('Unauthorized') if self.system?
    end

    def assign_identifier
      unless self.identifier || self.parent.nil?
        self.update_attribute :identifier, "#{self.parent.identifier}_#{self.id}"
      end
    end

end
