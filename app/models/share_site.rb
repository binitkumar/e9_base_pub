class ShareSite < ActiveRecord::Base
  acts_as_list

  DEFAULT_MAXIMUM_COUNT = 10

  scope :enabled,  lambda { where(:enabled => true) }
  scope :disabled, lambda { where(:enabled => false) }
  scope :active,   lambda { enabled.order(:position).limit(E9::Config[:maximum_share_site_count] || DEFAULT_MAXIMUM_COUNT) }
  scope :ordered,  lambda { order("position ASC") }

  before_validation :strip_url_whitespace

  validates :name,       :presence => true,
                         :length   => { :maximum => 100 }
  validates :url,        :presence => true,
                         :length   => { :maximum => 1000 },
                         :liquid   => true,
                         :format   => { :with => /^https?:\/\// }

  def prepare_url(page)
    Liquid::Template.parse(url).render('share_site' => self, 'page' => page)
  end

  def to_liquid
    E9::Liquid::Drops::ShareSite.new(self)
  end

  protected

  def filtered_url
    url.gsub(/page\.((?!url)\w+)\s*\}/, 'page.\1 | uri_escape }')
  end

  def strip_url_whitespace
    self.url.strip!
  end
end
