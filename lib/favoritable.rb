module Favoritable
  extend ActiveSupport::Concern
  
  included do
    has_many :favorites, :as => :favoritable, :dependent => :destroy
    has_many :favoriters, :through => :favorites, :source => :user, :class_name => 'User'

    before_save :update_favorites_roles

    scope :favorited_by, lambda {|user| joins(:favorites).where(:"favorites.user_id" => user.id) }

    # return all records of a "favoritable" subclass
    scope :favoritable, lambda {
      klasses = subclasses
      klasses.reject! {|k| !k.respond_to?(:favoritable) || !k.favoritable? }

      where :type => klasses.map(&:name)
    }
  end

  module ClassMethods
    def favoritable?
      true 
    end
  end

  protected

  def update_favorites_roles
    if self.respond_to?(:role) && self.role_changed?
      Favorite.update_all ["role = ?", read_attribute(:role)], ["favoritable_id = ? AND favoritable_type = ?", self.id, self.class.base_class]
    end
  end
end
