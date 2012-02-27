class AddEventEmail < ActiveRecord::Migration
  def self.up
    if email = SystemEmail.event_confirmation
      email.destroy!
    end

    opts = {}
    opts[:name] = "Event Confirmation Email"
    opts[:identifier] = SystemEmail::Identifiers::EVENT_CONFIRMATION
    opts[:subject] = "{{ config.site_name }}: {{ event.title }} Confirmation"
    opts[:html_body] = <<-BODY
<p>Thank you for registering for {{ event.title }}.</p>
<p>It will be held on {{ event.date }} at {{ event.time }}.</p>
<p>We're located at: <br/>
<br/>
The Arts Building<br/>
336 West 37th Street, Suite 950<br/>
New York, NY 10018<br/>
</p>
<p>Many thanks!</p>
<p>The {{ config.site_name }} Team<br/>{{ config.can_spam_mailing_address}}</p>
<p>PS: If you have any trouble or have questions, you can simply reply to this email and let us know!</p>
    BODY
    opts[:text_body] = <<-BODY
Thank you for registering for {{ event.title }}.

It will be held on {{ event.date }} at {{ event.time }}.

We're located at:

The Arts Building
336 West 37th Street, Suite 950
New York, NY 10018

Many thanks!

The {{ config.site_name }} Team
{{ config.can_spam_mailing_address}}

PS: If you have any trouble or have questions, you can simply reply to this email and let us know!
    BODY
    SystemEmail.create!(opts)
  end

  def self.down
    if email = SystemEmail.event_confirmation
      email.destroy
    end
  end
end
