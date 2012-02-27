class Admin::Settings::EmailController < Admin::SettingsController
  defaults :instance_name => 'settings', :resource_class => Settings
  use_tiny_mce :skip_default       => true,
               :unstyled           => true,
               :use_absolute_urls  => true

  protected

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:"admin.settings.emails.index_title")
  end
end
