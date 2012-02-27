class Region < ActiveRecord::Base
  attr_protected :view_id, :view_type

  scope :for_roleable, lambda {|roleable| joins(:region_type) & RegionType.for_roleable(roleable) }
  scope :for_role, lambda {|role| joins(:region_type) & RegionType.for_role(role) }

  scope :for_renderable, lambda {|renderable| joins(:region_type => :renderables).where('region_types_renderables.renderable_id = ?', renderable.id) }

  scope :layout_only, lambda {|*args| joins(:region_type) & RegionType.layout_only(args.shift) }

  #
  # View is polymorphic, a Layout or Page
  #
  belongs_to :view, :polymorphic => true

  # hack from rails docs to make polymorphic associations work # with an abstract base_class (View)
  def view_type=(s_type)
    super(s_type.to_s.classify.constantize.base_class.to_s)
  end

  #
  # Region Type
  #
  belongs_to :region_type

  delegate :role, :to => :region_type

  def region_type_id
    region_type.try(:id) || 0
  end

  def ==(other)
    other.is_a?(Region) && self.region_type_id == other.region_type_id
  end


  #
  # Nodes are mappings to Renderables and should be transparent
  #
  has_many :nodes, :autosave => true, :order => :position, :dependent => :destroy
  accepts_nested_attributes_for :nodes, :allow_destroy => true

  has_many :renderables, :through => :nodes

  # this is useful because newly built regions have nodes attached but no id, in
  # which case #renderables returns []
  def renderable_ids
    nodes.map(&:renderable_id)
  end

  def renderables=(renderables)
    return false unless renderables.all? {|r| r.is_a?(Renderable) }
    clear_renderables!
    add_renderables!(renderables)
  end

  def add_renderable(*records)
    options = records.extract_options!

    records.flatten.each do |renderable|

      # NOTE might be nice to do this as an error on the record which would raise on save attempt?
      if !renderable.region_types.include?(region_type)
        next unless options[:raise]
        raise "Exception in add_renderable: #{renderable.region_types.inspect} expected to include #{region_type.inspect}"
      end
      
      nodes.build(:renderable => renderable).tap do |node|
        node.save(:validate => false) if options[:save]
      end
    end
  end
  alias :add_renderables :add_renderable

  def add_renderable!(*records)
    add_renderable(*records, :save => true, :raise => true)
  end
  alias :add_renderables! :add_renderable!

  def clear_renderables!
    nodes.delete_all
  end

  #
  # - should copy name
  # - should not copy view
  # - should copy renderables (add nodes)
  #
  def copy
    self.class.new.tap do |c|
      c.name        = self.name
      c.domid       = self.domid
      c.region_type = self.region_type

      c.add_renderables(renderables)
    end 
  end

  def copy!
    copy.tap {|other| other.save(:validate => false) } 
  end

  ##
  # Misc
  #
  def to_liquid
    E9::Liquid::Drops::Region.new(self)
  end

end
