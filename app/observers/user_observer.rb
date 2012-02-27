class UserObserver < ActiveRecord::Observer
  def before_save(user)
    # favorite all auto favorite and not new record (no id, handled in after_create)
    favorite_all(user) if !user.new_record? && !user.prospect? && user.auto_favorite_changed? && user.auto_favorite?
    send_elevation_email_if_applicable(user)

    # return true so this passes
    true
  end

  def after_create(user)
    favorite_all(user) if user.auto_favorite?
    add_default_mailing_lists(user)

    unless user.prospect?
      user.send(:send_new_registrant_notifications)
    end
  end

  # called <tt>before_save</tt> when user's status is being elevated from 'prospect' to 'user'
  def before_elevate(user)
    add_default_mailing_lists(user)
    user.send(:send_revocation_instructions)
    user.send(:send_new_registrant_notifications)
  end

  protected

  def send_elevation_email_if_applicable(user)
    if user.role == 'employee' && %w(user).member?(user.role_was)
      if email = SystemEmail.elevation_notification
        email.send!(user)
      else
        Rails.logger.warn("Employee Elevation Email Not Found, user: #{user.email}")
      end
    end
  end

  def add_default_mailing_lists(user)
    user.mailing_lists |= MailingList.for_user(user)
  end

  def favorite_all(user)
    user.favorites.delete_all
    ContentView.favoritable.each {|favoritable| user.favorites.build(:favoritable => favoritable) }
  end
end
