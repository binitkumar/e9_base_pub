class Blog < Category
  include E9::Models::View
  acts_as_list

  belongs_to :layout
  has_many :blog_posts, :dependent => :restrict

  before_save :update_posts_roles

  validates_role

  scope :posted_on, lambda { 
    joins(:blog_posts).
      group("#{table_name}.id").
      having("count(#{BlogPost.table_name}.blog_id) > 0") 
  }

  def to_liquid
    E9::Liquid::Drops::Blog.new(self)
  end

  protected

  def update_posts_roles
    if self.role_changed?
      relations = []

      relations << self.blog_posts
      relations << Comment.where(:commentable_id => self.blog_post_ids, 
                                 :commentable_type => 'ContentView')

      relations.each do |relation|
        relation.update_all ["role = ?", read_attribute(:role)]
      end
    end
  end
end
