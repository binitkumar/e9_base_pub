class Admin::HelpController < Admin::ResourceController

  actions :show
  before_filter :add_show_breadcrumb

  protected
  
  def add_show_breadcrumb
    add_breadcrumb! resource.title
  end

  def e9_standard_help
    @_e9_standard_help ||= E9::Config[:e9_standard_help]
  end

  def e9_custom_help
    @_e9_custom_help ||= E9::Config[:e9_custom_help]
  end

  helper_method :e9_standard_help, :e9_custom_help

  #
  # NOTE admin::help_controller works with IR just 
  # like pages controller, but for a specific page
  #
  def resource
    @current_page ||= Page.find_by_identifier(Page::Identifiers::ADMIN_HELP)
  end
  alias :find_current_page :resource
end
