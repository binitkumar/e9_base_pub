class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favoritable, :polymorphic => true

  include E9::Roles::Roleable

  # monkeypatch association method to also store the subclass
  def favoritable_with_subclass(favoritable)
    self.sub_favoritable_type = favoritable.class.to_s
    favoritable_without_subclass(favoritable)
  end
  alias :favoritable_without_subclass :favoritable=
  alias :favoritable= :favoritable_with_subclass

  scope :valid, lambda { where(arel_table[:favoritable_id].eq(nil).not) }
  scope :paged, lambda {|limit, offset| limit > 0 ? limit(limit).offset(offset) : scoped }
  scope :for_user, lambda {|user| where(:user_id => user.to_param) }
  scope :of_type, lambda {|*types| where(:sub_favoritable_type => types.flatten.map {|t| t.to_s.classify }) }
  scope :of_pages, of_type('Page')
  scope :of_topics, of_type('Topic')

  def self.for_user_and_favoritable(user, favoritable)
    find_by_user_id_and_favoritable_id_and_favoritable_type(user.id, favoritable.id, favoritable.class.base_class.model_name)
  end

  protected

  def ensure_default_role
    if self.favoritable.respond_to?(:role)
      self.role = self.favoritable.role
    else
      super
    end
  end
end
