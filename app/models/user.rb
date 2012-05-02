class User < ActiveRecord::Base
  include E9::DestroyRestricted::Model
  include E9::Roles::Roleable
  include E9::ActiveRecord::AttributeSearchable

  class_attribute :author_roles
  self.author_roles = %w(employee administrator superuser)

  class_attribute :profile_roles
  self.profile_roles = %w(employee administrator superuser)

  def self.menu_linkable?; false end
  include Linkable

  include E9::ActiveRecord::Initialization

  has_many :topics, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :flags, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :mailing_lists, :through => :subscriptions
  has_many :content_views, :dependent => :restrict
  has_many :event_registrations, :dependent => :restrict

  validates :password,
            :presence     => { :if => lambda {|x| !x.prospect? && x.new_record? } },
            :confirmation => true,
            :length       => { :minimum => 5, :maximum => 20, :allow_blank => true }

  validates :first_name,
            :presence     => { :unless => lambda {|x| x.prospect? } }

  validates :username,
            :presence     => { :unless => lambda {|x| x.prospect? } },
            :length       => { :maximum => 25 },
            :uniqueness   => { :allow_blank => true, :case_sensitive => false }

  validates :email, 
            :presence     => true,
            :uniqueness   => { :case_sensitive => false },
            :email        => { :allow_blank => true },
            :length       => { :maximum => 500 }

  validates :first_name,
            :length       => { :maximum => 255 }

  validates :last_name,
            :length       => { :maximum => 255, :allow_blank => true }

  before_save :handle_elevation, :only => :update

  before_create :blank_password_data_defaults, :if => 'prospect?'

  #
  # for managing subscriptions tokens
  #
  attr_writer :subscriptions_token
  before_save :reset_subscriptions_token

  #
  # declarative_authorization impl -- see config/authorization_rules
  #
  def role_symbols 
    roles.map {|r| r.underscore.to_sym }
  end

  #
  # E9::Roles impl
  #
  self.default_role = E9::Roles.public
  def role; (read_attribute(:role) || self.class.default_role).role end

  #
  # Carrierwave
  #
  mounts_image :avatar
  def thumb(options = {}); self.avatar end
  
  ##
  # Devise
  #
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :trackable, :confirmable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :timeoutable, :revokable, :encryptable, :encryptor => :sha1, :timeout_in => 1.hour

  class << self
    def generate_username(user)
      n = user.hash.to_s[-4..-1].to_i

      loop do
        username = "user_#{n}"
        break username unless find(:first, :conditions => { :username => username })
        n += 1
      end
    end

    def has_scope?(s)
      scopes.keys.member?(s.intern)
    end

    def admin_ids
      connection.select_values(select(:id).where(:role => %w(administrator superuser)).to_sql)
    end

    def send_reset_password_instructions(attributes = {})
      recoverable = find_or_initialize_with_error_by(:email, attributes[:email], :not_found)
      recoverable.send_reset_password_instructions if recoverable.persisted?
      recoverable
    end

    def scope_roles_for_user(user)
      user.roles & SCOPE_ROLES 
    end

    def search_scopes_for_user(user)
      BASE_SEARCH_SCOPES + E9::Roles.scopeize(scope_roles_for_user(user))
    end

    def handle_bounced_emails!(*emails)
      emails.flatten!
      emails.uniq!

      if emails.empty?
        0
      else
        update_all(["has_bounced = ?", true], :email => emails).tap do |retv|
          user_ids = connection.select_values(has_bounced.select('id').to_sql)

          unless user_ids.empty?
            Subscription.destroy_all :user_id => user_ids
          end
        end
      end
    end
  end

  #
  # Scope
  #
  
  scope :default,         lambda {|*user_or_nil| for_roles(scope_roles_for_user(user_or_nil.shift) - %w(prospect)) }
  scope :flagged,         lambda {|*| where(:id => select("DISTINCT users.id").joins(:comments => :flag).map(&:id)) }
  scope :auto_favoriters, lambda { where(:auto_favorite => true) }
  scope :authors,         lambda { for_roles(author_roles) }
  scope :profiled,        lambda { for_roles(profile_roles) }
  scope :of_scope,        lambda {|*args| has_scope?(args.first) ? send(*args) : scoped }
  scope :prospects,       lambda { where(:role => :prospect) }
  scope :has_bounced,     lambda { where(:has_bounced => true) }
  scope :subscribed_to,   lambda {|*lists|
    lists.map! {|l| l.respond_to?(:id) && l.id || l.to_i }
    lists.compact!

    joins(:subscriptions).where('subscriptions.mailing_list_id' => lists)
  }

  scope :search, lambda {|query|
    any_attrs_like(%w(first_name last_name username email), query, :matcher => "%s%%")
  }

  BASE_SEARCH_SCOPES = [:default, :flagged].flatten.freeze

  SCOPE_ROLES = (E9::Roles.user_assignable | %w(prospect)).freeze
  SCOPE_ROLES.each do |role|
    class_eval %Q[scope :#{role.to_s.pluralize}, lambda {|*args| where(:role => "#{role}") }]
  end

  # devise_revokable
  def revoke!
    super do 
      self.comments.clear
      self.subscriptions.clear 
    end
  end

  def revoked?
    prospect? || super
  end

  # devise_registerable
  def send_reset_password_instructions
    generate_reset_password_token!
    SystemEmail.reset_password.send!(self)
  end

  def to_liquid
    E9::Liquid::Drops::User.new(self)
  end

  def to_polymorphic_args
    self
  end

  def name(opts = {})
    n = [last_name, first_name].reject {|n| n.blank? }.map(&:strip)
    opts[:reverse] ? n.join(', ') : n.reverse.join(' ')
  end

  def email_to
    first_name.present? && "#{first_name} <#{email}>" || email
  end

  def profiled?
    profile_roles.member? role
  end

  def author?
    author_roles.member? role
  end

  #
  # Has the type been set to 'User'?
  # This exists so we can validate Prospects based on type rather than actual class
  #

  def elevating?
    self.role > :prospect && self.role_was == 'prospect'
  end

  #
  # Set the type to 'User' for validations, etc
  #
  def to_user
    self.role = :user
    self
  end

  def to_prospect
    self.role = :prospect
    self
  end

  def as_json(options = {})
    {}.tap do |json|
      json[:email]      = self.email
      json[:errors]     = self.errors
      json[:first_name] = self.first_name
      json[:last_name]  = self.last_name
      json[:username]   = self.username
      json[:avatar]     = self.avatar
    end
  end

  protected

    def send_new_registrant_notifications
      list = self.class.admin_ids

      if list.blank?
        Rails.logger.warn("New Registrant Email: Failed with no IDs found")
      else
        SystemEmail.new_registrant.try(:send!, list, :sender => self)
      end
    end

    def method_missing(method_name, *args)
      method_name =~ /(.*)\?$/ ? self.role == $1 :  super
    end

    def handle_elevation
      if self.elevating?
        notify_observers :before_elevate
      end
    end

    def reset_subscriptions_token
      self.send(:write_attribute, :subscriptions_token, @subscriptions_token)
    end

    def _assign_initialization_defaults
      self.status ||= 'user'
    end

    def blank_password_data_defaults
      self.password_salt = ''
      self.encrypted_password = ''
    end

end
