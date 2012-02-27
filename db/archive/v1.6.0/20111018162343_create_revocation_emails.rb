class CreateRevocationEmails < ActiveRecord::Migration
  def self.up
    sanitizer = HTML::FullSanitizer.new

    unless SystemEmail.revocation_confirmation
      opts = {}
      opts[:name]       = "Revocation Confirmation"
      opts[:identifier] = SystemEmail::Identifiers::REVOCATION_CONFIRMATION
      opts[:subject]    = "{{ config.site_name }} -- Your account has been revoked"
      opts[:from]       = "admin@example.com"
      opts[:reply_to]   = "admin@example.com"
      opts[:html_body]  = <<-BODY
      <p>Hello</p>

      The account registered for #email# has been deactivated as per your request.
      BODY
      opts[:text_body] = sanitizer.sanitize(opts[:html_body])
      SystemEmail.create!(opts)
    end

    unless SystemEmail.revocation_instructions
      opts = {}
      opts[:name]       = "Revocation Instructions"
      opts[:identifier] = SystemEmail::Identifiers::REVOCATION_INSTRUCTIONS
      opts[:subject]    = "{{ config.site_name }} -- Your account has been created"
      opts[:from]       = "admin@example.com"
      opts[:reply_to]   = "admin@example.com"
      opts[:html_body]  = <<-BODY
      <p>Hello #email#</p>

      <p>You (or someone pretending to be you) has created an account at {% link_to root_url %}.</p>

      <p>If you chose to sign up with us, please disregard this email!</p>

      <p>However if this is not you, visit this url to take action: #revoke_account_url#</p>
      BODY
      opts[:text_body] = sanitizer.sanitize(opts[:html_body])
      SystemEmail.create!(opts)
    end


    unless SystemEmail.new_registrant
      opts = {}
      opts[:name]       = "New Registrant Notification"
      opts[:identifier] = SystemEmail::Identifiers::NEW_REGISTRANT
      opts[:subject]    = "{{ config.site_name }} - New Registrant"
      opts[:from]       = "admin@example.com"
      opts[:reply_to]   = "admin@example.com"
      opts[:html_body]  = <<-BODY
      <p>Greetings #first_name#!</p>

      <p>There is a new registrant at {{ config.site_name }}.  Visit {% link_to admin_users_url %} to approve or deny new registrants.</p>
      BODY
      opts[:text_body] = HTML::FullSanitizer.new.sanitize(opts[:html_body])
      SystemEmail.create!(opts)
    end
  end

  def self.down
    ids = [
      SystemEmail::Identifiers::REVOCATION_CONFIRMATION, 
      SystemEmail::Identifiers::REVOCATION_INSTRUCTIONS,
      SystemEmail::Identifiers::NEW_REGISTRANT
    ]

    SystemEmail.delete_all ["identifier in (?)", ids]
  end
end
