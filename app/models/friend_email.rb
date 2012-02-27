class FriendEmail < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :user_id, :class_name => 'User'
  belongs_to :link
  delegate :linkable, :to => :link

  validates :recipient_email, :presence => true, :email =>  { :allow_blank => true }, :length => { :maximum => 500 }
  validates :sender_email,    :presence => true, :email =>  { :allow_blank => true }, :length => { :maximum => 500 }
  validates :message,         :presence => true, :length => { :maximum => 500 }

  before_validation :set_sender_email_if_sender

  protected

  def set_sender_email_if_sender
    self.sender_email ||= self.sender.email if self.sender
  end
end
