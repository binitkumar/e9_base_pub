class Link < ActiveRecord::Base
  include E9::Roles::Roleable

  belongs_to :linkable, :polymorphic => true
  has_many :soft_links, :dependent => :destroy

  scope :menu_linkable, lambda {
    klasses = connection.select_values("select distinct(sub_linkable_type) from links")
    klasses.map! do |k| 
      klass = k.constantize rescue next
      k if klass.respond_to?(:menu_linkable?) && klass.menu_linkable?
    end
    klasses.compact!

    where(:sub_linkable_type => klasses)
  }

  # monkeypatch association method to also store the subclass
  def linkable_with_subclass(linkable)
    self.sub_linkable_type = linkable.class.to_s
    linkable_without_subclass(linkable)
  end
  alias :linkable_without_subclass :linkable=
  alias :linkable= :linkable_with_subclass

  delegate :title, :to_param, :url, :path, :to => :linkable, :allow_nil => true

  # TODO look into why this was, menus & fallback to root_url?
  def href
    to_polymorphic_args
  end

  def to_polymorphic_args
    linkable.try(:to_polymorphic_args) || [:root]
  end
end
