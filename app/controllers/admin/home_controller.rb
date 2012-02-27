class Admin::HomeController < AdminController
  before_filter :add_index_breadcrumb

  protected

  def add_index_breadcrumb
    add_breadcrumb!(@title = e9_t(:index_title))
  end

  def find_current_page
    @current_page = SystemPage.find_by_identifier(Page::Identifiers::ADMIN)
  end

  def e9_blog_url
    @_e9_blog_url ||= E9::Config[:e9_admin_home_blog_url] 
  end

  def e9_page_url 
    @_e9_page_url ||= E9::Config[:e9_admin_home_page_url] 
  end
  
  def e9_blog_exists? 
    !e9_blog_url.blank?  
  end

  def e9_page_exists? 
    !e9_page_url.blank?  
  end

  def e9_updates?
    e9_blog_exists? || e9_page_exists?
  end

  helper_method :e9_updates?, :e9_blog_exists?, :e9_page_exists?, :e9_blog_url, 
                :e9_page_url

end
