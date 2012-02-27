module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
    when /a non-existant page/
      '/anonexistantpage'
    when /register/
      new_user_registration_path
    when /sign in/i
      new_user_session_path
    when /the blog/i
      blog_posts_path
    when /sign out/i
      destroy_user_session_path
    when /edit my profile/
      edit_profile_path
    when /my profile/
      profile_path
    when /Forgot Password/i
      new_user_password_path
    when /Reset Password/i
      edit_user_password_path
    when /admin users/i
      admin_users_path
    when /admin pages/i
      admin_user_pages_path
    when /pending emails?|admin emails/i
      admin_user_emails_path
    when /site settings/i
      admin_site_settings_path
    when /edit user page for "([^\"]*)"$/i 
      edit_admin_user_path(User.find_by_email($1))
    when /my unsubscribe page for "([^\"]*)"$/
      edit_subscription_path(@my_user.reload.subscriptions.detect{|s| s.mailing_list.name == $1 }.to_param)
    when /the unsubscribe page/
      edit_subscription_path('somebadtoken')
    when /admin custom help/
      admin_custom_help_path
    when /admin help/
      admin_help_path
    when /admin admin help/
      admin_admin_help_path
    when /forums/
      forums_path
    when /the "([^\"]*)" forum/
      forum_path(Forum.find_by_title($1))
    when /admin home/
      admin_root_path


    
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
