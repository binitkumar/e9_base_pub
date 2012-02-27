module E9::Roles
  module Roleable
    extend ActiveSupport::Concern

    delegate :is?, :includes?, :included, :lesser, :is_omnipotent?, :to => :role, :prefix => true
    delegate :roles, :to => :role

    def role
      read_attribute(:role).role 
    end

    def ensure_default_role
      self.role = self.class.default_role if self.read_attribute(:role).blank?
    end
    protected :ensure_default_role

    module ClassMethods
      def validates_role
        validates :role, :inclusion => { :in => E9::Roles.list }
      end

      def excluding_roles_scope_condition(*roles)
        role  = arel_table[:role]
        roles = roles.flatten.map(&:to_s)
        cond  = role.in(roles).not
        cond  = cond.and(role.eq(nil).not) if roles.include?(E9::Roles.bottom)
        cond 
      end
    end
    
    included do
      class_attribute :default_role
      self.default_role = E9::Roles.bottom 

      alias :initialize_without_role :initialize

      def initialize(attributes = nil, &block)

        initialize_without_role(attributes) do |obj|
          obj.role = self.class.default_role if obj.read_attribute(:role).nil?
          yield obj if block_given?
        end
      end

      # TODO check to ensure record has "role" column on include
      
      before_validation :ensure_default_role

      # NOTE this a little subtle, .for_roles is for exact passed roles (no inclusion),
      #      while .for_role is for the roles inclusive in the passed role

      scope :for_roles, lambda {|*roles| 
        role  = arel_table[:role]
        roles = roles.flatten.map(&:to_s)
        cond  = role.in(roles)
        cond  = cond.or(role.eq(nil)) if roles.include?(E9::Roles.bottom)
        where(cond)
      }

      # NOTE these two methods could/should be consolidated
      scope :for_role, lambda {|role| for_roles(role.roles) }
      scope :for_roleable, lambda {|roleable| roleable.role_is_omnipotent? ? scoped : for_roles(roleable.roles) }

      scope :exclude_roles, lambda {|*roles| where(excluding_roles_scope_condition(*roles)) }
      scope :exclude_roleable, lambda {|roleable| exclude_roles(roleable.roles) }

      scope :bottom_roled, lambda { for_roles(E9::Roles.bottom) }
      scope :top_roled, lambda { for_roles(E9::Roles.top) }

      scope :public_roled, lambda { for_roles(E9::Roles.public.roles) }
    end
  end
end
