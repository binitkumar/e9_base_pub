class Note < ActiveRecord::Base
  include E9::ActiveRecord::AttributeSearchable

  belongs_to :owner, :foreign_key => 'contact_id', :class_name => 'Contact', :inverse_of => :owned_notes

  has_many :note_assignments, :inverse_of => :note, :dependent => :delete_all
  has_many :contacts, :through => :note_assignments, :source => :assigned, :source_type => 'Contact'
  has_many :deals,    :through => :note_assignments, :source => :assigned, :source_type => 'Deal'

  alias :assignments :note_assignments

  validates :title,   :presence => true
  validates :owner, :presence => true

  class_attribute :create_attachment_thumbs
  self.create_attachment_thumbs = true

  has_many :attachments, :as => :owner, :inverse_of => :owner, :dependent => :delete_all
  accepts_nested_attributes_for :attachments, :allow_destroy => true, :reject_if => :reject_attachment?

  before_save :force_completed, :if => 'self.class == Note'

  scope :active, lambda {|v=true| completed(!v) }
  scope :completed, lambda {|v=true| where(:completed => v) }
  scope :search, lambda {|query| any_attrs_like(:title, :details, query) }
  scope :by_contact, lambda {|contact| 
    id = contact.respond_to?(:id) ? contact.id : contact
    where(:contact_id => contact.id) 
  }

  def status
    'note'
  end

  def details
    read_attribute(:details) || ''
  end

  protected

    def reject_attachment?(attrs)
      attrs['id'].blank? && attrs['file'].blank?
    end
    
    def force_completed
      self.completed = true
      self.completed_at ||= DateTime.now
    end

end
