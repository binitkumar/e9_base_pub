class Topic < ContentView
  include Linkable
  include Hittable

  self.default_role = E9::Roles.public

  ##
  # associations
  #
  belongs_to :author, :foreign_key => :user_id, :class_name => 'User'

  belongs_to :forum

  # invalidate cache for forum when saved/updated
  after_save { forum.save(:validate => false) if forum.present? }
  before_destroy { forum.save(:validate => false) if forum.present?}

  mounts_image :thumb
  def fallback_thumb; author.try(:thumb) end

  def role
    forum.present? ? forum.role : self.class.default_role
  end

  ##
  # validations
  #
  validates :forum_id, :presence => true
  validates :body,     :presence => true, :length => { :maximum => 1000 }

  ##
  # callbacks
  #
  after_create :assign_permalink_and_publish!
  before_save :sanitize_body
  before_save :set_forum_role

  ## 
  # scopes
  #
  scope :search, lambda {|*args|
    opts = args.extract_options!
    term = args.shift

    if term.blank?
      where("1=0")
    else
      find_scope = scoped.published
      conditions = any_attrs_like_scope_conditions(:body, :title, term, opts)

      if opts[:roles] 
        find_scope = find_scope.where(:role => opts.delete(:roles))
      end

      find_scope.
        where(conditions).
        # union_of(find_scope.tagged_with(term)).
        order('published_at DESC')
    end
  }

  # NOTE using arel_table[column] here is broken and ends up aliasing the table to _2 for the order scope
  #      e.g. order(arel_table[:updated_at].desc)
  scope :recent, lambda { order("#{table_name}.updated_at desc") }

  ##
  # class methods
  #
  class << self
    def menu_linkable?; false end
    def favoritable?;   true  end
  end

  ##
  # instance methods
  #
  
  def parent
    forum
  end

  def layout
    forum.try(:layout) || self.class.default_layout || Forum.default_layout
  end

  def region(domid)
    forum.try(:region, domid)
  end

  def renderables
    forum.try(:renderables) || []
  end

  def to_param
    (permalink || '').parameterize
  end

  def sanitized_body
    self.class.sanitize_and_strip(self.read_attribute(:body) || '')
  end

  # for linkable
  def to_polymorphic_args
    self
  end

  def to_liquid
    E9::Liquid::Drops::Topic.new(self)
  end

  def rss_title; title end
  def rss_description; body end
  def rss_author; author.try(:name) end
  def rss_date; published_at end

  # are topics display options always true?
  def display_social_bookmarks?;  true end
  def display_author_info?; true end
  def display_date?; true end
  def display_labels?; true end
  def allow_comments?; true end
  def display_actions?; true end

  def description_field
    :body
  end

  ##
  # Social impl
  #
  def _facebook_template; E9::Config[:facebook_forum_template] end
  def _twitter_template;  E9::Config[:twitter_forum_template]  end

  def _post_to_twitter?;  E9::Config[:twitter_forums_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_forums_by_default] end

  protected

  def ensure_default_role
    if self.forum
      self.role = self.forum.role
    else
      super
    end
  end

  def set_forum_role
    if forum_id_changed?
      self.role = self.forum.role
    end
  end

  def assign_default_preferences
    super

    self.display_social_bookmarks = true
  end

  def sanitize_body
    self.body = sanitized_body
  end
end
