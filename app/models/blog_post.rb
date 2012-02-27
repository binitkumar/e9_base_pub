class BlogPost < Page
  include E9::Publishable
  include Hittable
  include Linkable

  mounts_image :thumb, :fallback_url => 'owner#author_thumb_url'
  def author_thumb_url() author.try(:avatar_url) end

  scope :in_blog,       lambda {|blog| where(:blog_id => blog.respond_to?(:id) ? blog.id : blog) }

  # >= and <= in these scopes to avoid issues if blog posts have exactly the same published_at
  scope :posted_before, lambda {|post| post.is_a?(BlogPost) ? excluding(post.id).where('published_at <= ?', post.published_at) : where("1 = 0") }
  scope :posted_after,  lambda {|post| post.is_a?(BlogPost) ? excluding(post.id).where('published_at >= ?', post.published_at) : where("1 = 0") }

  ##
  # associations
  #
  belongs_to :blog, :touch => true
  delegate :role, :to => :blog
  delegate :title, :to => :blog, :prefix => true

  # invalidate cache for blog when saved/updated
  after_save { blog.save(:validate => false) if blog.present? }
  before_destroy { blog.save(:validate => false) if blog.present? }

  ##
  # validations
  #
  validates :blog,      :presence => true
  validates :body,      :presence => true

  ##
  # class methods
  #
  class << self
    def menu_linkable?;   false end
    def favoritable?;     true  end
  end

  ##
  # instance methods
  #

  def parent
    blog
  end

  # for record sequence
  def previous_record
    BlogPost.in_blog(blog_id).posted_before(self).published.order('published_at DESC').limit(1).first
  end

  # for record sequence
  def next_record
    BlogPost.in_blog(blog_id).posted_after(self).published.order('published_at ASC').limit(1).first
  end

  def has_own_breadcrumbs?
    false
  end

  def to_polymorphic_args
    [self.blog, self].compact
  end

  def to_liquid
    E9::Liquid::Drops::BlogPost.new(self)
  end

  def _post_to_twitter?;  E9::Config[:twitter_blog_posts_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_blog_posts_by_default] end

  protected

  def ensure_default_role
    if self.blog
      self.role = self.blog.read_attribute(:role)
    else
      super
    end
  end

  def assign_default_preferences
    super 

    self.display_social_bookmarks = E9::Config[:blog_show_social_bookmarks] if self.display_social_bookmarks.nil?
    self.display_date             = E9::Config[:blog_show_date]             if self.display_date.nil?
    self.display_actions          = E9::Config[:blog_display_actions]       if self.display_actions.nil?
    self.display_author_info      = E9::Config[:blog_show_author_info]      if self.display_author_info.nil?
    self.display_labels           = E9::Config[:blog_show_labels]           if self.display_labels.nil?
    self.allow_comments           = E9::Config[:blog_allow_comments]        if self.allow_comments.nil?
  end
end
