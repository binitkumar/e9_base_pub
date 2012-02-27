module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, :as => :commentable, :dependent => :destroy, :inverse_of => :commentable
    has_many :commenters, :through => :comments, :source => :author, :class_name => 'User'

    before_save :update_comments_roles
  end

  protected

  def update_comments_roles
    if self.respond_to?(:role) && self.role_changed?
      Comment.update_all ["role = ?", read_attribute(:role)], ["commentable_id = ? AND commentable_type = ?", self.id, self.class.base_class.to_s]
    end
  end
end
