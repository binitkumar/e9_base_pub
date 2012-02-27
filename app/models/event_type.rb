class EventType < ActiveRecord::Base
  include E9::Permalink
  self.permalinked_column = :name
  self.always_generate_permalink = true

  validates :name, :uniqueness => true
  has_many :events, :foreign_key => :parent_id, :dependent => :restrict

  validates :name, :presence => true, :uniqueness => true

  def role
    'administrator'.role
  end

  scope :ordered, lambda { order('position ASC') }
  scope :in_use, lambda {
    ids = connection.select_values(
      "SELECT DISTINCT(content_views.parent_id) FROM content_views " +
      "WHERE content_views.type = 'Event' AND content_views.parent_id IS NOT NULL")

    where(:id => ids)
  }

  acts_as_list
end
