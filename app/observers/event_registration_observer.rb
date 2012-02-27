class EventRegistrationObserver < ActiveRecord::Observer
  observe :event_registration

  def before_update(record)
    if record.event_id_changed? && email = SystemEmail.event_confirmation
      email.send!(record.user || record.email, {
        :event       => record.try(:event),
        :transaction => record.event_transaction
      })
    end

    # TODO email.send! returns false if it's queued.  It probably shouldn't
    true
  end
end
