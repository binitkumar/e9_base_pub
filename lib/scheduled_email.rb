module ScheduledEmail
  extend ActiveSupport::Concern

  # NOTE the pending and sent scopes are on Email (TODO refactor this...)

  def sent?
    status == Email::Status::SENT
  end

  def pending?
    status == Email::Status::PENDING
  end

  def send!(*args)
    opts = args.extract_options!
    super(*args, opts).tap do |result|
      mark_as_sent(false, args.first) unless opts[:test]
    end
  end

  protected

  def mark_as_sent(override = false, target = nil)
    if override || !sent?
      self.status = Email::Status::SENT
      self.delivery_date = Date.today
      self.sent_count = if self.mailing_list.present?
                          self.mailing_list.subscriptions_count
                        elsif target.is_a?(Array)
                          target.length
                        end
      self.save(:validate => false)
    end
  end

  module ClassMethods
    # NOTE only mails attached to lists can be scheduled
    def deliver_scheduled
      pending.where(:delivery_date => Date.today).each(&:send!)
    end
  end
end
