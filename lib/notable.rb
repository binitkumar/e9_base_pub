module Notable
  extend ActiveSupport::Concern

  included do
    has_many :note_assignments, :as => :assigned, :dependent => :delete_all

    # NOTE that notes is notes and tasks, where tasks is tasks only.  This is really only for a scope on the tasks_controller
    has_many :notes, :through => :note_assignments

    #has_many :notes, :through => :note_assignments, :source => :note, :conditions => 'notes.type IS NULL OR notes.type = "Note"'
    has_many :tasks, :class_name => 'Task', :through => :note_assignments, :source => :note, :conditions => 'notes.type = "Task"'
  end
end
