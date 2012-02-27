class LinkableSystemPage < SystemPage
  include Linkable

  class << self
    def home_page
      find_by_identifier(Page::Identifiers::HOME)
    end
  end

  def home_page?
    identifier == Page::Identifiers::HOME
  end

  def role
    home_page? && E9::Roles.bottom || super
  end

  def to_polymorphic_args
    permalink ? permalink_for_url : '/'
  end

  # hack: permalink should begin with / or http:// always
  def permalink_for_url
    if permalink =~ /^https?:\/\//
      permalink
    else
      permalink.sub /^([^\/]?)/, '/\1'
    end
  end

  protected

  def ensure_default_role
    if home_page?
      self.role = E9::Roles.bottom
    elsif read_attribute(:role).blank?
      self.role = self.class.default_role
    end
  end
end
