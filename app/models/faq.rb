class Faq < Category
  acts_as_list :scope => 'categories.role = \"#{role}\"'

  before_save :update_lists_if_role_changed
  before_save :update_questions_roles

  has_many :questions, :dependent => :restrict

  scope :questioned, lambda { joins(:questions).group("#{table_name}.id").having("count(#{Question.table_name}.faq_id) > 0") }
  
  class << self
    def menu_linkable?
      false
    end
  end

  def to_polymorphic_args
    # guest roled should return false (no url prefix)
    [self, {:role => !role.guest? && role}]
  end

  def to_liquid
    E9::Liquid::Drops::Faq.new(self)
  end

  def to_param
    id.to_s
  end

  protected

  # temporarily put us back in the old role list and fix it based on
  # our removal, then set position to nil and add to the new list's bottom
  def update_lists_if_role_changed
    if self.role_changed?
      new_role, self.role = self.role, self.role_was
      decrement_positions_on_lower_items if in_list?
      self.position = nil
      self.role = new_role
      add_to_list_bottom
    end
  end

  def update_questions_roles
    if self.role_changed?
      Question.update_all ["role = ?", self.read_attribute(:role)], ["faq_id = ?", self.id]
    end
  end
end
