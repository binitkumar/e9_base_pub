class Flag < ActiveRecord::Base
  belongs_to :flaggable, :polymorphic => true
  belongs_to :user

  scope :comments, lambda { where(:flaggable_type => 'Comment') }
  scope :for_comment, lambda {|comment| comments.where(:flaggable_id => comment.to_param) }
  
  def self.comment_count
    # TODO inefficient and 
    comments.where(arel_table[:flaggable_id].eq(nil).not).group('flaggable_id').count.values.sum
  end
end
