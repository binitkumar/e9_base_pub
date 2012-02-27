class AddElevationEmail < ActiveRecord::Migration
  def self.up
    if email = SystemEmail.elevation_notification
      email.destroy!
    end

    opts = {}
    opts[:name] = "Employee Confirmation Email"
    opts[:identifier] = SystemEmail::Identifiers::ELEVATION_NOTIFICATION
    opts[:subject] = "You have been confirmed as employee of {{ config.site_name }}"
    opts[:html_body] = <<-BODY
<p>Dear #first_name#,</p>
<p>You have just been confirmed as a employee of {{ config.site_name }}.</p>
<p>Go to {% link_to edit_profile_url %} to enter your extended profile information.</p>
<p>Many thanks!</p>
<p>The {{ config.site_name }} Team<br />{{ config.can_spam_mailing_address}}</p>
<p>PS: If you have any trouble or have questions, you can simply reply to this email and let us know!</p>
    BODY
    opts[:text_body] = <<-BODY
Dear #first_name#,

You have just been confirmed as a employee of {{ config.site_name }}.

Go to {% link_to edit_profile_url %} to enter your extended profile information.

Many thanks!

The {{ config.site_name }} Team
{{ config.can_spam_mailing_address}}

PS: If you have any trouble or have questions, you can simply reply to this email and let us know!
    BODY
    SystemEmail.create!(opts)
  end

  def self.down
    if email = SystemEmail.elevation_notification
      email.destroy!
    end
  end
end
