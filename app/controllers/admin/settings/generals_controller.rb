class Admin::Settings::GeneralsController < Admin::SettingsController
  defaults :instance_name => 'settings', :resource_class => Settings

  carrierwave_column_methods :avatar, :favicon, :user_page_thumb, :blog_post_thumb, :question_thumb, :context => :admin

  protected

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:"admin.settings.generals.index_title")
  end
end
