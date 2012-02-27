class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :mailing_list, :counter_cache => true

  before_create :generate_unsubscribe_token

  scope :excluding, lambda {|*ids| where(arel_table[:user_id].in(ids.flatten).not) }

  def to_param
    unsubscribe_token.parameterize
  end

  def to_liquid
    E9::Liquid::Drops::Subscription.new(self)
  end
  
  protected

  def generate_unsubscribe_token
    self.unsubscribe_token = ActiveSupport::SecureRandom.hex(25) until unique_token?
  end

  def unique_token?
    !unsubscribe_token.nil? && self.class.where(:unsubscribe_token => unsubscribe_token).count == 0 
  end
end
