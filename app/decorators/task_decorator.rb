class TaskDecorator < NoteDecorator
  decorates :task

  def as_json(options = {})
    super(options).tap do |hash|
      hash[:completed_at] = model.completed? ? h.l(model.completed_at.try(:to_date) || '') : ''
      hash[:due_date]     = h.l(model.due_date.to_date)
    end
  end
end
