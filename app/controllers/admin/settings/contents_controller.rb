class Admin::Settings::ContentsController < Admin::SettingsController
  defaults :instance_name => 'settings', :resource_class => Settings

  protected

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:"admin.settings.contents.index_title")
  end
end
