module SettingsHelper
  def facebook_access_token_refresh_link
    uri = facebook_auth_uri

    if uri.blank?
      e9_t :facebook_access_token_instructions
    else
      link_to e9_t(:facebook_access_token_refresh_link), uri
    end
  end
end
