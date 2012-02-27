class Question < ContentView
  include Linkable
  include Searchable

  mounts_image :thumb
  def fallback_thumb; E9::Config.instance.try(:question_thumb) end

  ##
  # validations
  #
  validates :title,  :length   => { :maximum => 200, :tokenizer => html_tokenizer }
  validates :faq,    :presence => true
  validates :body,   :presence => true

  ##
  # scopes
  #
  scope :ordered, lambda { order("#{table_name}.position ASC") }

  scope :search, lambda {|*args|
    opts = args.extract_options!
    term = args.shift

    find_scope = recent

    if opts[:roles] 
      find_scope = find_scope.where(:role => opts.delete(:roles))
    end

    find_scope.any_attrs_like([:title, :text_version], term).includes(:faq)
  }

  ##
  # associations
  #
  belongs_to :faq, :touch => true
  acts_as_list :scope => :faq_id

  def role
    faq.present? ? faq.role : self.class.default_role
  end

  ##
  # callbacks
  #
  before_save  :prepare_text_version
  before_save  :update_lists_if_parent_changed
  before_save  :set_faq_role

  after_create :assign_permalink_and_publish!

  class << self
    def menu_linkable?; false end
    def favoritable?; false end
  end

  include E9::Feedable
  def rss_title; title end
  def rss_description; text_version end
  def rss_author; author.try(:name) end
  def rss_date; created_at end

  def to_polymorphic_args
    # guest roled should return false (no url prefix)
    [self, {:role => !role.guest? && role}]
  end

  def to_liquid
    E9::Liquid::Drops::Question.new(self)
  end

  # legacy table alias
  def answer; body end

  protected

  def ensure_default_role
    if self.faq
      self.role = self.faq.role
    else
      super
    end
  end

  def set_faq_role
    if faq_id_changed?
      self.role = self.faq.role
    end
  end

  def update_lists_if_parent_changed
    if self.faq_id_changed?
      new_faq_id, old_faq_id = self.faq_id, self.faq_id_was
      self.faq_id = old_faq_id
      decrement_positions_on_lower_items if in_list?
      self.position = nil
      self.faq_id = new_faq_id
      add_to_list_bottom
    end
  end

end
