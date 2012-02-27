class Forum < Category
  include E9::Models::View
  include E9::ActiveRecord::Initialization

  self.default_role = E9::Roles.public

  acts_as_list

  belongs_to :layout
  has_many :topics, :dependent => :restrict

  before_save :update_topics_roles

  def to_liquid
    E9::Liquid::Drops::Forum.new(self)
  end

  def to_polymorphic_args
    self
  end

  protected

  def _assign_initialization_defaults
    self.role = self.class.default_role if self.read_attribute(:role).blank?
  end

  def update_topics_roles
    if self.role_changed?
      relations = []

      relations << self.topics
      relations << Comment.where(:commentable_id => self.topic_ids,
                                 :commentable_type => 'ContentView')

      relations.each do |relation|
        relation.update_all ["role = ?", read_attribute(:role)]
      end
    end
  end
end
