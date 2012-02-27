class AddRoleToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :role, :string

    Comment.reset_column_information
    Comment.all.each do |comment|
      commentable = comment.commentable
      if commentable.respond_to?(:role)
        comment.role = commentable.role
        comment.save(:validate => false)
      end
    end
  end

  def self.down
    remove_column :comments, :role
  end
end
