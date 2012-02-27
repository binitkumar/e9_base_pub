class Task < Note
  validates :due_date, :date => true

  def toggle_completed!
    if persisted?
      args = {}
      args[:completed]    = !completed?
      args[:completed_at] = Time.now.utc if !completed?

      success = self.class.update_all(args, self.class.primary_key => id) == 1
      reload
      success
    end
  end

  def status
    if completed?
      'completed'
    else
      case due_date <=> Date.today
      when -1 then 'overdue'
      when  1 then 'future'
      else         'today'
      end
    end
  end
end
