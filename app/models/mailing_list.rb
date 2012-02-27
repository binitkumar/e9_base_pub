class MailingList < ActiveRecord::Base
  include E9::Roles::Roleable
  include E9::DestroyRestricted::Model
  include E9::ActiveRecord::Initialization

  has_many :subscriptions, :dependent => :restrict
  has_many :subscribers,   :through   => :subscriptions, :class_name => "User", :source => :user
  has_many :emails

  validates :identifier, :uniqueness => { :allow_blank => true }
  validates :name, :description, :presence => true, :length => { :maximum => 100 }

  validates_role

  scope :deletable,   lambda { where(:system => false) }
  scope :newsletters, lambda { where(:newsletter => true) }

  class << self
    def default
      newsletter
    end

    def newsletter
      find_by_identifier(Identifiers::NEWSLETTER)
    end

    def comment_updates
      find_by_identifier(Identifiers::COMMENT_UPDATES)
    end

    def new_content_alerts
      find_by_identifier(Identifiers::NEW_CONTENT_ALERTS)
    end

    def for_user(user)
      case user.role
      when 'prospect';  []
      when 'user';      [comment_updates]
      else []
      end
    end
  end

  protected

    def _assign_initialization_defaults
      self.role ||= 'guest'
    end

  module Identifiers
    NEWSLETTER           = 'newsletter'
    COMMENT_UPDATES      = 'coment_updates'
    NEW_CONTENT_ALERTS   = 'new_content_alerts'
  end
end
