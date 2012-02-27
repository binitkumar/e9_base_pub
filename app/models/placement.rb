class Placement < Renderable
  include E9::ActiveRecord::Initialization

  scope :owned_by, lambda {|owner| 
    # TODO is there a simple default scope for polymorphic children?
    owner ? where(:owner_id => owner.id).where(:owner_type => owner.class.base_class)
          : where('1=0') 
  }

  # NOTE It's necessary to set the inverse on this association or placements
  # will not be updateable, e.g. on changing layouts.
  #
  # I suspect this has to do with the name, as @owner is used on reflections
  # internally and is most likely overwritten by the record caching the @owner
  # association?
  # 
  belongs_to :owner, :polymorphic => true, :inverse_of => :placements
  belongs_to :placeholder, :foreign_key => :associated_id

  delegate :name, :width, :to => :placeholder

  def length
    placeholder ? placeholder.width : 0
  end

  protected

  #
  # Placements are 'system' by default to avoid the validation
  # on name (as they don't have a name)
  #
  def _assign_initialization_defaults
    self.system = true
  end
end
