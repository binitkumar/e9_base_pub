class SeedNewEmails < ActiveRecord::Migration
  def self.up
    unless SystemEmail.revocation_instructions
      opts = {}
      opts[:name] = "Registration Confirmation"
      opts[:identifier] = SystemEmail::Identifiers::REVOCATION_INSTRUCTIONS
      opts[:subject] = "You are now registered at {{ config.site_name }}"
      opts[:html_body] = <<-BODY
<p>Dear #first_name#,</p>
<p>You are now registered at {% link_to root_url %}.</p>
<p>If you chose to sign up with us, please disregard this email as no further action is required.</p>
<p>However, if this was not you, you can revoke this account by clicking the link or pasting it into your browser:<br />#revoke_account_url#</p>
<p>Many thanks!</p>
<p>The {{ config.site_name }} Team</p><br />{{ config.can_spam_mailing_address}}</p>
<p>PS: If you have any trouble or have questions, you can simply reply to this email and let us know!</p>
      BODY
      opts[:text_body] = <<-BODY
Dear #first_name#,

You are now registered at {% link_to root_url %}.

If you chose to sign up with us, please disregard this email as no further action is required.

However, if this was not you, you can revoke this account by clicking the link or pasting it into your browser:
#revoke_account_url# 

Many thanks!

The {{ config.site_name }} Team
{{ config.can_spam_mailing_address}}

PS: If you have any trouble or have questions, you can simply reply to this email and let us know!
      BODY
      SystemEmail.create!(opts)
    end

    unless SystemEmail.new_registrant
      opts = {}
      opts[:name] = "Admin Registrant Notification"
      opts[:identifier] = SystemEmail::Identifiers::NEW_REGISTRANT
      opts[:subject] = 'You have a new registrant at {{ config.site_name }}'
      opts[:html_body] = <<-BODY
<p>Dear #first_name#,</p>
<p>There is a new registrant at {{ config.site_name }}.</p>
<p>Visit {% link_to admin_users_url %} to review new registrations.</p>
<p>Many thanks!</p>
<p>The {{ config.site_name }} Team<br />{{ config.can_spam_mailing_address}}</p>
<p>PS: If you have any trouble or have questions, you can simply reply to this email and let us know!</p>
      BODY
      opts[:text_body] = <<-BODY
Dear #first_name#,

There is a new registrant at {{ config.site_name }}.

Visit {% link_to admin_users_url %} to review new registrations.

Many thanks!

The {{ config.site_name }} Team
{{ config.can_spam_mailing_address}}

PS: If you have any trouble or have questions, you can simply reply to this email and let us know!
      BODY
      SystemEmail.create!(opts)
    end
  end

  def self.down
    SystemEmail.revocation_instructions.try(:destroy)
    SystemEmail.new_registrant.try(:destroy)
  end
end
