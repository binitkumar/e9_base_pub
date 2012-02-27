class Node < ActiveRecord::Base
  belongs_to :renderable
  belongs_to :region

  scope :with_accessible_data, lambda { for_renderable_type('PlaceHolder') }
  scope :for_view, lambda {|v| where(:region_id => v.region_ids) }

  scope :for_renderable_type, lambda {|*type| 
    joins(:renderable).
      where(Renderable.arel_table[:type].in(type.flatten.map {|t| t.to_s.classify }))
  }

  def role
    'administrator'.role
  end

  acts_as_list :scope => :region

  delegate :name, :form_field_name, :to => :renderable, :allow_nil => true
end
