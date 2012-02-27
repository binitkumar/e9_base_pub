module Admin::SettingsHelper
  def settings_link(settings, subtitle = nil)
    poly_args =  [[:admin_settings, settings]]
    poly_args << { :anchor => subtitle } if subtitle

    link_to e9_t(subtitle || :index_title, :scope => ['admin','settings', settings.to_s.pluralize]), polymorphic_path(*poly_args)
  end
end
