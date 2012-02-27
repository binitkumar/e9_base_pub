class RegionType < ActiveRecord::Base
  include E9::Roles::Roleable
  include E9::ActiveRecord::AttributeSearchable

  self.default_role = E9::Roles.top

  # 
  # Every Region belongs to a RegionType, used to determine the renderables it can be assigned.
  #
  has_many :regions, :dependent => :destroy

  #
  # RegionTypes have a many-to-many relationship with:
  #
  # Renderables: A region can only be assigned renderables that match with it's region type.
  # Layouts:     A layout has a collecion of region types, which it uses to prototype new Views
  #
  has_and_belongs_to_many :layouts
  has_and_belongs_to_many :renderables

  scope :layout_only, lambda {|*args| arg = args.shift; where(:layout_only => arg.nil? ? true : arg) }

  validates_role
end
