class SystemEmail < Email
  validates :from,        :email      => { :allow_blank => true },
                          :length     => { :maximum => 1000 }
  validates :reply_to,    :email      => { :allow_blank => true },
                          :length     => { :maximum => 1000 }
  validates :identifier,  :presence   => true, :uniqueness => { :case_sensitive => false }

  class << self
    def event_confirmation
      find_by_identifier(Identifiers::EVENT_CONFIRMATION)
    end

    def friend_email
      find_by_identifier(Identifiers::FRIEND_EMAIL)
    end

    def reset_password
      find_by_identifier(Identifiers::RESET_PASSWORD)
    end

    def new_content_alert
      find_by_identifier(Identifiers::NEW_CONTENT_ALERT)
    end

    def comment_update
      find_by_identifier(Identifiers::COMMENT_UPDATE)
    end

    def new_registrant
      find_by_identifier(Identifiers::NEW_REGISTRANT)
    end

    def revocation_instructions
      find_by_identifier(Identifiers::REVOCATION_INSTRUCTIONS)
    end

    def revocation_confirmation
      find_by_identifier(Identifiers::REVOCATION_CONFIRMATION)
    end

    def elevation_notification
      find_by_identifier(Identifiers::ELEVATION_NOTIFICATION)
    end
  end

  def list_managed?
    Identifiers::LIST_MANAGED.member? identifier
  end

  protected

    def _do_send(opts = {})
      case identifier
      when Identifiers::RESET_PASSWORD
        merges[:reset_password_url] = recipients.map do |user|
          [:edit_user_password_url, :reset_password_token => user.reset_password_token]
        end
      when Identifiers::REVOCATION_INSTRUCTIONS
        merges[:revoke_account_url] = recipients.map do |user|
          [:confirm_user_revocation_url, :revocation_token  => user.revocation_token]
        end
      end

      super
    end

  module Identifiers
    RESET_PASSWORD          = 'reset_password'
    COMMENT_UPDATE          = 'comment_update'
    NEW_CONTENT_ALERT       = 'new_content_alert'
    FRIEND_EMAIL            = 'email_a_friend'
    NEW_REGISTRANT          = 'new_registrant'
    REVOCATION_INSTRUCTIONS = 'revocation_instructions'
    REVOCATION_CONFIRMATION = 'revocation_confirmation'
    ELEVATION_NOTIFICATION  = 'elevation_notification'
    EVENT_CONFIRMATION      = 'event_confirmation'

    LIST_MANAGED = [
      COMMENT_UPDATE, NEW_CONTENT_ALERT
    ]
  end
end
