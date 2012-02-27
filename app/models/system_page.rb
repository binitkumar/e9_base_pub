class SystemPage < Page

  validates :identifier, :presence => true, :uniqueness => { :case_sensitive => false }

  # TODO remove
  scope :linkable, lambda {|n| Rails.logger.warn("SystemPage#linkable deprecated"); where("permalink IS NOT NULL") }
  scope :unlinkable, lambda {|n| where(arel_table[:type].eq('LinkableSystemPage').not) }

  class << self
    def favoritable?; false end
  end

  def to_param
    identifier.parameterize
  end
  
  def has_own_breadcrumbs?
    false
  end

  def display_labels?; false end
  def display_comments?; false end
  def display_social_bookmarks?; false end
  def display_date?; false end
  def display_author_info?; false end
  def allow_comments?; false end
end
