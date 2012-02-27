class EventTransactionObserver < ActiveRecord::Observer
  observe :event_transaction

  def after_create(record)
    if email = SystemEmail.event_confirmation
      if record.event_registrations.any?
        target = record.event_registrations.map(&:user)

        unless target.present?
          target = record.event_registrations.first.email
        end

        email.send!(target, {
          :event       => record.try(:event),
          :transaction => record
        })
      else
        Rails.logger.warning(
          "EventTransaction Confirmation ID:#{record.id} failed to send " +
              "as no registrations were found"
        )
      end
    end
  end
end
