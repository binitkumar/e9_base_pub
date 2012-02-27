class ContentView < ActiveRecord::Base
  include Commentable
  include Favoritable
  include Searchable
  include E9Tags::Model
  include E9::ActiveRecord::STI
  include E9::ActiveRecord::AttributeSearchable
  include E9::Roles::Roleable
  include E9::HTML
  include E9::Permalink
  include E9::Social::Clients
  include E9::DestroyRestricted::Model
  include E9::Models::View

  # NOTE It's necessary to set the inverse on this association or placements
  # will not be updateable, e.g. on changing layouts.
  #
  # I suspect this has to do with the name, as @owner is used on reflections
  # internally and is most likely overwritten by the record caching the @owner
  # association?
  # 
  has_many :placements, :as => :owner, :inverse_of => :owner, :dependent => :delete_all
  accepts_nested_attributes_for :placements, :allow_destroy => false

  ##
  # Associations
  #
  belongs_to :author, :foreign_key => :user_id, :class_name => 'User'
  delegate :name, :to => :author, :prefix => true, :allow_nil => true

  belongs_to :layout

  # only slides use this, but it's up here so we can use the relation
  has_many :slideshow_assignments, :foreign_key => :slide_id, :dependent => :restrict

  mounts_images :images

  ##
  # validations
  #
  validates :title,   :presence => true, :format => { :without => /\Anew\Z/ }
  validates :author,  :presence => true
  validates :custom_css_classes, :format => { :with => /\A([a-z][\w-]*\s?)*\Z/i, :allow_blank => true }
  validates_role

  html_safe_columns :title

  def initialize_with_defaults(attributes = nil, &block)
    initialize_without_defaults(attributes) do
      self.send(:assign_default_preferences)
      yield self if block_given?
    end
  end
  alias_method_chain :initialize, :defaults

  class << self
    def master
      @_master ||= where(:type => name).where(:master => true).first
    end

    def default_layout(force_reload = false)
      @default_layout = nil if force_reload
      @default_layout ||= Layout.default_for_page_class(self)
    end

    def linkable_subclasses
      subclasses_with_ancestor(Linkable)
    end

    def system_page_subclasses
      subclasses_with_ancestor(SystemPage)
    end

    def publishable_subclasses
      subclasses_with_ancestor(E9::Publishable)
    end

    def unpublishable_subclasses
      subclasses - publishable_subclasses
    end

    def linkable_publishable_subclasses
      publishable_subclasses & linkable_subclasses
    end

    def linkable_unpublishable_subclasses
      unpublishable_subclasses & linkable_subclasses
    end

    def feedable_unpublishable_subclasses
      linkable_unpublishable_subclasses - system_page_subclasses
    end
  end

  ##
  # scopes
  #

  # published_at is set on create, so it's ok for ordering in all content_view cases
  scope :recent,           lambda {|*n| limit(n.shift).order_by_published_at(:desc) }
  scope :published,        lambda { where(:published => true) }
  scope :order_by_published_at, lambda {|*args| order_by_attribute(:published_at, *args) }
  scope :order_by,         lambda {|*args|
    options = args.extract_options!
    column  = args.shift
    order arel_table[column].send(options[:reverse] ? :desc : :asc)
  }

  scope :pages,            lambda { of_type('UserPage', 'LinkableSystemPage') }
  scope :blog_posts,       lambda { of_type('BlogPost') }
  scope :slides,           lambda { of_type('Slide') }
  scope :user_pages,       lambda { of_type('UserPage') }
  scope :system_pages,     lambda { of_type('SystemPage') }

  scope :linkables,        lambda { where(:type => linkable_subclasses.map(&:name)) } 
  scope :publishables,     lambda { where(:type => publishable_subclasses.map(&:name)) }
  scope :unpublishables,   lambda { where(:type => unpublishable_subclasses.map(&:name)) }

  # TODO make a generic scope like .of_type_and_published_if_publishable(array_of_classes) to simplify these scopes
  scope :public_facing,    lambda { where(((arel_table[:type].in(linkable_publishable_subclasses.map(&:name))).and(arel_table[:published].eq(true))).or(arel_table[:type].in(linkable_unpublishable_subclasses.map(&:name)))) }
  scope :feedable,         lambda { where(((arel_table[:type].in(linkable_publishable_subclasses.map(&:name))).and(arel_table[:published].eq(true))).or(arel_table[:type].in(feedable_unpublishable_subclasses.map(&:name)))) }

  # site_mappable means guest roled && linkable && (publishable and published || not publishable)
  scope :site_mappable, lambda { 
    public_facing.not_of_type('Question').where(
      arel_table[:type].eq('Topic').and(arel_table[:role].in(['guest','user'])).
        or(arel_table[:role].eq('guest'))
    )
  }

  scope :of_blog,      lambda {|*args| ids = args.flatten.compact; ids.present? ? where(:blog_id  => ids) : empty_scope }
  scope :of_forum,     lambda {|*args| ids = args.flatten.compact; ids.present? ? where(:forum_id => ids) : empty_scope }
  scope :of_faq,       lambda {|*args| ids = args.flatten.compact; ids.present? ? where(:faq_id => ids) : empty_scope }
  scope :of_layout,    lambda {|*args| ids = args.flatten.compact; ids.present? ? where(:layout_id => ids) : empty_scope }
  scope :of_slideshow, lambda {|*args| ids = args.flatten.compact; ids.present? ? joins(:slideshow_assignments) & SlideshowAssignment.where(:slideshow_id => ids) : empty_scope }

  # NOTE of_parent does not care what the "parent" is
  scope :of_parent,    lambda {|id| where(:parent_id => id) }

  scope :for_year,                       lambda {|y| d = Date.parse("#{y}-1-1"); where(:published_at => d..(d + 1.year)) }
  scope :for_month_and_year,             lambda {|m, y| d = Date.parse("#{y}-#{m}-1"); where(:published_at => d..(d + 1.month)) }
  scope :published_before,               lambda {|datetime| published.where(arel_table[:published_at].lt(datetime)) }
  scope :published_after,                lambda {|datetime| published.where(arel_table[:published_at].gt(datetime)) }
  scope :published_after_month_in_year,  lambda {|m, y| published_after(DateTime.new(y.to_i, m.to_i) + 1.month) }
  scope :published_before_month_in_year, lambda {|m, y| published_before(DateTime.new(y.to_i, m.to_i)) }

  scope :empty_scope, lambda { where("1=0") }

  # TODO modulize order_by_#{attribute} order scoping
  scope :order_by_attribute, lambda {|*args| 
    attr_name, dir = args
    dir = [:desc, 'desc'].include?(dir) ? :desc : :asc

    # NOTE issue with Arel incorrectly aliasing arel_table if it is called from a subclass first
    #order(arel_table[attr_name.to_sym.send(dir)) 
    order("#{table_name}.#{attr_name} #{dir}") 
  }

  scope :in_slideshow_order, lambda { joins(:slideshow_assignments).order('slideshow_assignments.position ASC') }

  # NOTE the direction is typically (and should be DESC). The direction construct
  # only exists to make this comply with the feed widget UI.
  scope :top, lambda {|*args|
    direction = args.shift.to_s.upcase == "ASC" && "ASC" || "DESC"
    order "hit_date #{direction}, hit_count #{direction}, created_at #{direction}"
  }

  ##
  # Instance Methods
  #

  include E9::Feedable

  def rss_title; title end
  def rss_description; meta_description end
  def rss_author; author_name end
  def rss_date; published_at end

  DESCRIPTION_LENGTH      = 400

  def description(options = {})
    truncate send(description_field), options.reverse_merge!(:length => DESCRIPTION_LENGTH)
  end

  def description_field
    :text_version
  end

  META_DESCRIPTION_LENGTH = 200

  def meta_title
    read_attribute(:meta_title).presence || title
  end

  def meta_description
    read_attribute(:meta_description).presence || description(:length => META_DESCRIPTION_LENGTH)
  end

  def meta_keywords
    read_attribute(:meta_keywords).presence || tags.join(', ')
  end

  #
  def text_version
    read_attribute(:text_version) || ''
  end

  # was the record published during this load?
  def newly_published?
    !!@newly_published
  end

  ##
  # Social impl
  #
  def _post_to_twitter?;  false end
  def _post_to_facebook?; false end

  def generate_facebook_argument_hash(*args)
    super(*args).merge({
      :link        => url,
      :caption     => E9::Config[:domain_name],
      :name        => title,
      :description => description,
      :picture     => Linkable.urlify_path(thumb.url)
    })
  end

  def parent
    nil
  end

  protected

  def publish!
    self.published            = true
    self.previously_published = true
    self.published_at         = DateTime.now

    save(:validate => false)

    @newly_published = true
    notify_observers :publish_content
  end

  def assign_permalink_and_publish!
    self.assign_permalink(:force => true)
    publish!
  end

  def should_publish?
    self.published? && !self.previously_published?
  end

  def publish_if_should_publish!
    assign_permalink_and_publish! if self.should_publish?
  end

  # something that is un-published is as though it never was published 
  # (previously_published reverts to false)
  def unpublish!
    self.published = false
    self.previously_published = false
    save(:validate => false)
  end

  def assign_default_preferences
    self.published_at ||= DateTime.now
  end

  def prepare_text_version
    self.text_version = self.class.full_sanitize_and_strip(body) unless body.nil?
  end
end
