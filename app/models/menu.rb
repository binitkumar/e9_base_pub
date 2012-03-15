class Menu < ActiveRecord::Base
  include E9::DestroyRestricted::Model



  # NOTE before_destroy must be added *before* acts_as_nested_set's callback
  before_destroy :touch_ancestors

  ##
  # Acts as nested set setup
  #
  acts_as_nested_set :dependent => :restrict
  alias :descendents :descendants

  # NOTE after_save must be added *after* acts_as_nested_set's callback
  after_save :touch_ancestors_with_reload

  html_safe_columns :name

  include E9::Roles::Roleable
  validates_role

  belongs_to :link

  scope :roots, lambda { where(:parent_id => nil) }
  scope :editable_for_user, lambda {|user| user.role.is_omnipotent? ? scoped : where(:editable => true) }

  class << self
    def master
      find_by_identifier('main_menu') || where(:system => true).first 
    end
  end

  def master?
    self.class.master == self
  end

  def for_page(page)
    self_and_descendants.find_by_id(page.soft_links.map(&:id)) if page.kind_of?(Linkable)
  end

  def child_with_descendant(menu)
    children.detect {|child| menu.is_or_is_descendant_of?(child) } if menu
  end

  def child_with_descendant_for_page(page)
    child_with_descendant(for_page(page)) if page
  end

  # TODO change menu link_text to title to match page
  def link_text
    name
  end

  def has_children?
    @has_children ||= !children.empty?
  end

  def root?
    @is_root ||= (root == self)
  end

  def depth
    @depth ||= ancestors.length
  end

  def links_in_hierarchy
    root.self_and_descendants.map(&:link).compact
  end

  def linkables_in_hierarchy
    links_in_hierarchy.map(&:linkable)
  end

  def self.map_with_level(menus)
    retv = []
    each_with_level(menus) {|menu, level| retv << [menu, level] }
    retv
  end

  alias_method :link_without_linkable_cast=, :link=

  def link=(_link)
    _link = _link.link if _link.respond_to?(:link)
    self.link_without_linkable_cast = _link
  end

  def linkable=(linkable)
    self.link = linkable.link
  end

  # to_a[0] parent
  # to_a[1] all descs
  # to_a[1][n] nth child branch
  # to_a[1][n][0] nth child object
  # to_a[1][n][1] nth child children branch
  # to_a[1][n][1][m] nth child children mth child branch
  # to_a[1][n][1][m][0] nth child children mth child object
  # to_a[1][n][1][m][1] nth child children mth child branch
  # and so on
  def to_array
    parents = []

    top_array = [self]
    c_arr = top_array

    self.class.base_class.each_with_level(descendants.includes(:link => :linkable)) do |menu, level|
      case level <=> parents.count
        when 0 # same level
          # set current array as new sibling array containing menu
          c_arr = [menu]                           

          # and push current array (the new sibling array) to current parent
          parents.last[1] << c_arr                 

        when 1 # descend
          # push a child array if the current level does no thave one
          c_arr << [] if c_arr.length == 1
          
          # and push the sibling array into that array
          c_arr[1] << [menu]

          # push the current array to be the current parent
          parents  << c_arr

          # and reset the current as the new child array
          c_arr = c_arr[1].last

        when -1 # ascend
          # pop parents up to the parent of the new menu
          parents.pop while parents.count > level

          # and proceed to add new sibling as though level had been 0
          c_arr = [menu]
          parents.last[1] << c_arr
      end
    end

    top_array
  end 

  def destroy
    unless children.empty?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:children])
    end

    super
  end

  protected

  def touch_ancestors(reload = false)
    self.reload if reload

    ancestral_ids = self.ancestors.map(&:id)

    unless ancestral_ids.blank?
      Menu.update_all ["updated_at = ?", DateTime.now], ["id in (?)", ancestral_ids]
    end
  end

  def touch_ancestors_with_reload
    touch_ancestors(true)
  end
end
