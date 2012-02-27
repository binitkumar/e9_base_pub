class Settings < ActiveRecord::Base
  include SocialFeeds

  def role; 'administrator'.role; end

  cattr_writer :_default_config_files
  self._default_config_files = []
  cattr_reader :_defaults_loaded, :_default_attribute_values

  PAGE_SUBMENU_VIEWS = %w(pagination expanded)
  BLOG_VIEWS         = %w(digest normal)
  BLOG_SUBMENU_VIEWS = %w(pagination archive)

  before_save do |record|
    record.updated_at = DateTime.now
  end

  validates  :name,                       :presence => true, :uniqueness => { :case_sensitive => false }

  validates  :admin_records_per_page,     :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates  :avatar_size,                :numericality => { :only_integer => true }
  validates  :slide_embeddable_width,     :numericality => { :only_integer => true }
  validates  :slide_embeddable_height,    :numericality => { :only_integer => true }
  validates  :banner_height,              :numericality => { :only_integer => true }
  validates  :banner_width,               :numericality => { :only_integer => true }
  validates  :blog_pagination_records,    :presence => true, :numericality => { :only_integer => true }
  validates  :blog_pagination_records,    :presence => true, :numericality => { :only_integer => true }
  validates  :slide_pagination_records,   :presence => true, :numericality => { :only_integer => true }
  validates  :blog_submenu,               :inclusion => { :in => BLOG_SUBMENU_VIEWS } 
  validates  :blog_view,                  :inclusion => { :in => BLOG_VIEWS } 
  validates  :contact_form_page_title,    :length => { :maximum => 200 }
  validates  :contact_thanks_page_title,  :length => { :maximum => 200 }
  validates  :content_icon_size,          :numericality => { :only_integer => true }
  validates  :copyright_start_year,       :length => { :is => 4 }
  validates  :default_html_email,         :presence => true, :length => { :maximum => 10000 } 
  validates  :default_menu_truncation,    :numericality => { :only_integer => true }
  validates  :default_meta_description,   :length => { :maximum => 200 }
  validates  :default_meta_keywords,      :length => { :maximum => 200 }
  validates  :default_text_email,         :presence => true, :length => { :maximum => 10000 } 
  #validates  :domain_name,                :domain => true, :length => { :maximum => 100 }
  validates  :excerpt_display_chars,      :numericality => { :only_integer => true }
  validates  :feed_max_title_characters,  :numericality => { :only_integer => true }
  validates  :feed_records,               :numericality => { :only_integer => true, :greater_than => 0 }
  validates  :feed_summary_characters,    :numericality => { :only_integer => true }
  validates  :forum_pagination_records,   :presence => true, :numericality => { :only_integer => true }
  validates  :google_analytics_code,      :length => { :maximum => 10000 }
  validates  :home_records_per_page,      :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  #validates  :layout_preview_height,      :numericality => { :only_integer => true }
  #validates  :layout_preview_width,       :numericality => { :only_integer => true }
  validates  :maximum_share_site_count,   :numericality => { :only_integer => true }
  validates  :menu_icon_size,             :numericality => { :only_integer => true }
  validates  :menu_record_count,          :numericality => { :only_integer => true }
  validates  :page_submenu,               :inclusion => { :in => PAGE_SUBMENU_VIEWS } 
  validates  :records_per_page,           :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates  :sales_email,                :email => true, :length => { :maximum => 500 }
  validates  :search_records_per_page,    :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates  :share_site_icon_size,       :numericality => { :only_integer => true }
  validates  :system_mailing_address,     :email => { :allow_blank => true }
  validates  :site_email_address,         :email => { :allow_blank => true }
  validates  :site_name,                  :presence => true, :length => { :maximum => 50 }

  def initialize_with_defaults(attributes = nil, &block)
    initialize_without_defaults(attributes) do
      self.attributes = self.class.default_attribute_values
      yield self if block_given?
    end
  end
  alias_method_chain :initialize, :defaults

  #
  # TODO better persistent defaults for settings
  # 
  # Currently settings do persistent defaults in a multi-stop process, and I'm not sure which parts are necessary, which aren't,
  # and whether or not there's a better way.  AR + AM + Rails access attribute methods in several different ways and to avoid
  # failing specs this implementation currently covers a lot of bases.
  #
  # 1st, settings are defaulted on initialization
  # 2nd, attribute methods are monkeypatched to do lookup to defaults.  This covers sends, eg. model.some_attr_with_a_default
  # 3rd, read_attribute is overridden, which covers attribute() and [] calls, _for_validation and _before_type_cast are in for good measure
  #
  # Also, write_attribute is overridden to always nullify values if they're "blank", enabling this to work at all (no empty strings)
  #

  def read_attribute_for_validation(attr_name)
    !(v = super).nil? ? v : self.class.fetch_attribute_default(attr_name)
  end

  def read_attribute_before_type_cast(attr_name)
    !(v = super).nil? ? v : self.class.fetch_attribute_default(attr_name)
  end

  def read_attribute(attr_name)
    !(v = super).nil? ? v : self.class.fetch_attribute_default(attr_name)
  end

  def write_attribute(attr_name, attr_value)
    super(attr_name, attr_value.blank? ? nil : attr_value)
  end

  class << self
    def defaulting_attributes
      columns_hash.keys - %w(id name) rescue []
    end

    # TODO typecasting default columns
    def define_attribute_methods
      return if attribute_methods_generated?

      super

      defaulting_attributes.each do |key|
        module_eval <<-STR, __FILE__, __LINE__ + 1
          alias :#{key}_without_lookup :#{key}
          def #{key}; !(v = #{key}_without_lookup).nil? ? v : self.class.fetch_attribute_default(:#{key}) end
        STR
      end
    end

    def fetch_attribute_default(attr_name)
      default_attribute_values[attr_name]
    end

    def load_defaults
      @@_default_attribute_values ||= @@_default_config_files.inject(HashWithIndifferentAccess.new) do |defaults, filename|
        Rails.logger.debug("Settings: Merging YAML from #{filename}")
        defaults.merge(YAML.load_file(filename)[Rails.env])
      end
    end

    def add_default_config_file(*filename)
      @@_default_config_files |= filename 
    end

    alias :add_default_config_files :add_default_config_file

    def reset_default_attribute_values!
      @@_default_attribute_values = nil
    end

    def default_attribute_values
      load_defaults if @@_default_attribute_values.blank?
      @@_default_attribute_values
    end
  end
end
