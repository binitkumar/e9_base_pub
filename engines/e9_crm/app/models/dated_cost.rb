#
# Encapulates a Cost and a Date, used to track costs by
# date so sums for date ranges can be generated.
#
class DatedCost < ActiveRecord::Base
  include E9::ActiveRecord::Initialization

  money_columns :cost
  belongs_to :costable, :polymorphic => true

  belongs_to :deal
  belongs_to :contact

  scope :for_deals, lambda { where('dated_costs.deal_id IS NOT NULL') }
  scope :for_contacts, lambda { where('dated_costs.contact_id IS NOT NULL') }

  validates :date, :date => true

  # costs are never negative, rather how they are applied is determined by
  # whether or not they are a credit
  validates :cost, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }

  def self.default_scope
    order('dated_costs.created_at ASC')
  end

  delegate :status, :name, :closed_at, :created_at, :to => :deal, :prefix => true, :allow_nil => true
  delegate :name, :to => :contact, :prefix => true, :allow_nil => true

  def cost
    credit ? value * -1 : value
  end

  def value
    Money.new(read_attribute(:cost) || 0)
  end

  def as_json(options={})
    {}.tap do |hash|
      hash[:id]             = self.id
      hash[:label]          = self.label.presence
      hash[:cost]           = self.cost
      hash[:formatted_cost] = "%.2f" % self.cost
      hash[:label]          = self.label
      hash[:date]           = self.date
      hash[:costable_type]  = self.costable_type.try(:underscore)
      hash[:costable_id]    = self.costable_id

      hash.merge!(options)
    end
  end

  protected

    def _assign_initialization_defaults
      self.date ||= Date.today
    end
end
