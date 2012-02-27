class NoteAssignmentDecorator < BaseDecorator
  decorates :note_assignment

  def as_json(options={})
    except = Array.wrap(options[:except])

    {}.tap do |hash|
      hash[:id] = model.id

      unless except.member?(:assigned)
        hash[:type] = model.assigned_type
        hash[:assigned] = model.assigned.decorate 
      end

      unless except.member?(:note)
        hash[:note] = model.note.decorate
      end
    end
  end
end
