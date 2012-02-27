class Category < ActiveRecord::Base
  include E9::Roles::Roleable
  include E9::DestroyRestricted::Model
  include E9::Permalink
  include Linkable
  include E9::Social::Clients

  belongs_to :author, :foreign_key => :user_id, :class_name => 'User'
  after_create :assign_permalink!

  mounts_image :thumb
  def fallback_thumb; E9::Config.instance.try(:user_page_thumb) end

  html_safe_columns :title

  # TODO modulize order_by_#{attribute} order scoping
  scope :order_by_attribute, lambda {|*args| 
    attr_name, dir = args
    dir = [:desc, 'desc'].include?(dir) ? :desc : :asc
    order(arel_table[attr_name.to_sym].send(dir)) 
  }
  scope :order_by_title, lambda {|*args| order_by_attribute(:title, *args) }
  scope :ordered, lambda { order("#{table_name}.position ASC") }

  scope :site_mappable, lambda { 
    where(
      arel_table[:type].eq('Forum').and(arel_table[:role].in(['guest','user'])).
        or(arel_table[:role].eq('guest'))
    )
  }

  validates :title,            :presence => true, 
                               :length   => { :maximum => 50, :tokenizer => html_tokenizer }
  validates :meta_keywords,    :length   => { :maximum => 200 }
  validates :meta_description, :length   => { :maximum => 200 }

  SCOPES = [:forums, :faqs, :slideshows, :blogs]
  scope :forums,       where(:type => 'Forum')
  scope :faqs,         where(:type => 'Faq')
  scope :blogs,        where(:type => 'Blog')
  scope :slideshows,   where(:type => 'Slideshow')

  include E9::Feedable
  def rss_title; title end
  def rss_description; description || meta_description || title end
  def rss_author; author.try(:name) end
  def rss_date; created_at end

  ##
  # social clients impl
  #
  attr_writer :twitter_comment, :facebook_comment

  def _twitter_comment;   @twitter_comment end
  def _post_to_twitter?;  true end
  def post_to_twitter; _post_to_twitter? end

  def _facebook_comment;  @facebook_comment end
  def _post_to_facebook?; true end
  def post_to_facebook; _post_to_facebook? end

  def to_param
    (permalink || '').parameterize
  end

  def to_polymorphic_args
    self
  end
end
