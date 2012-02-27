require "active_support/core_ext"
require "declarative_authorization"

module E9
  module Roles
    def self.engine; Authorization::Engine.instance end
    def self.list; engine.roles.map(&:to_s) end 
    def self.roles_for(role); engine.send(:flatten_roles, [role.to_sym]).map(&:role) end
    def self.title_for(role); engine.title_for(role.to_sym) end
    def self.description_for(role); engine.description_for(role.to_sym) end
    def self.exists?(role); list.include?(role.role) end
    def self.bottom; list.first end
    def self.public; 'user'.role end
    def self.top; list.last end
    def self.all; list end

    def self.omnipotent; engine.omnipotent_roles.map(&:to_s) end
    def self.omnipotent_role?(role); omnipotent.member?(role) end

    def self.logged_out_roles; [bottom] end
    def self.logged_in_roles; list - logged_out_roles end
    def self.logged_out_role?(role); logged_out_roles.member?(role) end
    def self.logged_in_role?(role); logged_in_roles.member?(role) end

    def self.content_assignable
      engine.roles.select {|role| engine.description_for(role) =~ /\bcontent_assignable\b/ }.map(&:to_s)
    end

    def self.user_assignable
      engine.roles.select {|role| engine.description_for(role) =~ /\buser_assignable\b/ }.map(&:to_s)
    end

    def self.scopeize(roles)
      roles.map {|role| role.to_s.pluralize.to_sym }
    end
  end
end

# TODO Roleable should be a more basic interface, with an activerecord interface for AR roleables

class NilClass
  delegate :is?, :is_omnipotent?, :includes?, :included, :lesser, :to => :role, :prefix => true
  delegate :roles, :to => :role
  def role; ::E9::Roles::Role.new(::E9::Roles.bottom) end
end

class String
  delegate :is?, :is_omnipotent?, :includes?, :included, :lesser, :to => :role, :prefix => true
  delegate :roles, :to => :role
  def role; ::E9::Roles::Role.new(self) end
end

class Symbol
  delegate :is?, :is_omnipotent?, :includes?, :included, :lesser, :to => :role, :prefix => true
  delegate :roles, :to => :role
  def role; ::E9::Roles::Role.new(self.to_s) end
end

class Authorization::GuestUser
  delegate :is?, :is_omnipotent?, :includes?, :included, :lesser, :to => :role, :prefix => true
  delegate :roles, :to => :role
  def role; ::E9::Roles::Role.new(::E9::Roles.bottom) end
end

class Authorization::AnonymousUser
  delegate :is?, :is_omnipotent?, :includes?, :included, :lesser, :to => :role, :prefix => true
  delegate :roles, :to => :role
  def role; ::E9::Roles::Role.new(::E9::Roles.bottom) end
end
