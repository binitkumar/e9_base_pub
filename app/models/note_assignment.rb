class NoteAssignment < ActiveRecord::Base
  belongs_to :assigned, :polymorphic => true
  belongs_to :note, :inverse_of => :note_assignments

  delegate :name, :to => :assigned, :prefix => true
end
