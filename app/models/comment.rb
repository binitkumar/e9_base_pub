class Comment < ActiveRecord::Base
  include Flaggable, Linkable, Searchable

  include E9::HTML

  include E9::Roles::Roleable

  LINK_REGEX  = /http:\/\/\S+/
  LINK_STRING = '<a href="\0" rel="nofollow external">\0</a>'

  before_save :sanitize_body

  validates :body,   :presence => true, :length => { :maximum => 1000 }
  validates :author, :presence => true

  scope :search, lambda {|*args|
    opts = args.extract_options!
    term = args.shift

    find_scope = recent

    if opts[:roles] 
      find_scope = find_scope.where(:role => opts.delete(:roles))
    end

    # can't eager load commentable with pagination
    #attr_like(:body, term).includes(:commentable)
    find_scope.attr_like(:body, term)
  }

  ##
  # scopes
  #
  scope :paged, lambda {|limit, offset| limit > 0 ? limit(limit).offset(offset) : scoped }
  scope :by_user, lambda {|u| where(:user_id => u.to_param) }
  scope :by_user_distinct_on_commentable, lambda {|u| where("id in (select id from comments where user_id = ? group by commentable_id, commentable_type)", u.to_param) }
  scope :on_commentable, lambda {|c| where(:commentable_type => c.class.base_class.model_name, :commentable_id => c.id) }
  scope :on_type, lambda {|t| where(:commentable_type => t.to_s.classify) }
  scope :recent, lambda {|*n| limit(n.first).order("#{table_name}.created_at DESC") }
  scope :deleted, lambda {|*args| where(:deleted => args.first == false ? false : true) }

  scope :attr_like, lambda {|attr, string| where(self.arel_table[attr].matches("%#{string}%")) }
  scope :any_attrs_like, lambda {|attrs, string|
    conditions = Array(attrs).map {|attr| arel_table[attr].matches("%#{string}%") }
    conditions = conditions[1..-1].inject(conditions.first) {|c1, c2| c1.or(c2) }
    where(conditions)
  }

  # this should be defined in flaggable but re-defining it here (for clarity with the bugginess of count w/ distinct) 
  # NOTE flagged.count will return the count of flags, which may be incorrect if more than one flag was attached to a comment
  scope :flagged, proc {|f| select("DISTINCT comments.*").joins(:flag) }

  class << self
    def menu_linkable?
      false
    end
  end

  ##
  # associations
  #
  belongs_to :commentable, :polymorphic => true, :counter_cache => true, :touch => :updated_at, :inverse_of => :comments
  
  belongs_to :author, :foreign_key => :user_id, :class_name => 'User'
  belongs_to :deleter, :class_name => 'User'

  def thumb
    author.try(:thumb)
  end

  def title
    commentable.title rescue ''
  end

  def sanitized_body
    self.class.sanitize_and_strip(self.read_attribute(:body) || '')
  end

  def to_polymorphic_args
    if !commentable.blank?
      [commentable.to_polymorphic_args, self].flatten
    else
      [:forums]
    end
  end

  def to_liquid
    E9::Liquid::Drops::Comment.new(self)
  end

  include E9::Feedable
  def rss_title; title end
  def rss_description; sanitized_body end
  def rss_author; author.try(:name) end
  def rss_date; created_at end

  def delete!(opts = {})
    self.deleted = true
    self.deleter = opts[:deleter] 
    # NOTE ensure deletion of *all* flags, even though this is a has_one so there *should* only be one
    Flag.delete(Flag.for_comment(self))
    self.save!
  end

  protected

  def ensure_default_role
    if self.commentable.respond_to?(:role)
      self.role = self.commentable.role
    else
      super
    end
  end

  def sanitize_body
    self.body = sanitized_body
  end

end
