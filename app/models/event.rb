class Event < Page
  include E9::Publishable
  include Hittable
  include Linkable

  scope :event_type, lambda {|et| 
    if et.respond_to?(:to_i) && et.to_i > 0
      of_parent(et)
    else
      joins(:event_type).where('event_types.name' => et)
    end
  }

  scope :future, lambda {|v=true| where("event_time #{v ? '>=' : '<'} ?", Time.now) }
  scope :past, lambda { future(false) }
  scope :ordered, lambda { order('event_time ASC') }

  scope :with_registration_count, lambda {|active=true|
    inner_scope = 
      EventRegistration.select("COUNT(*) count, event_id").group(:event_id)

    inner_scope = inner_scope.cancelled(false) if active

    select("#{table_name}.*, IFNULL(registrations.count, 0) registration_count").
      joins("LEFT OUTER JOIN (#{inner_scope.to_sql}) registrations " +
                "ON registrations.event_id = #{table_name}.id")
  }

  belongs_to :event_type, :foreign_key => :parent_id

  before_save :delete_costs_if_free

  has_many :event_transactions, :dependent => :restrict
  has_many :event_registrations, :dependent => :restrict

  has_record_attributes :costs
  alias :costs :cost_attributes

  def cost_attributes_attributes
    cost_attributes.map {|c|
       { 'options' => c.options, 'value' => c.value }
    }
  end

  mounts_image :thumb
  def fallback_thumb; E9::Config.instance.try(:user_page_thumb) end

  def label
    [title, event_time.presence && I18n.localize(event_time, :format => :event)].join(' - ')
  end

  ##
  # validations
  #
  validates :body, :presence => true
  validates :event_capacity, :presence => true, :numericality => { :only_integer => true, :greater_than => 0, :allow_blank => true }
  validates :event_max_guests, :presence => true, :numericality => { :only_integer => true, :allow_blank => true }
  validates :event_last_register_date, :presence => true
  validates :event_time, :presence => true

  class << self
    def favoritable?; true end
  end

  def destroy
    unless soft_links.empty?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:soft_links])
    end

    super
  end

  def copy
    super.tap do |copied| 
      if thumb.present?
        copied.thumb.attributes = thumb.attributes
      end

      copied.event_type = self.event_type

      copied.cost_attributes_attributes = self.cost_attributes_attributes
    end
  end

  def to_polymorphic_args
    self
  end

  def to_liquid
    E9::Liquid::Drops::Event.new(self)
  end

  def accepts_guests?
    event_max_guests > 0
  end

  def registrations_closed?
    event_time.present? && Time.now > event_time || 
      event_last_register_date.present? && Date.today > event_last_register_date
  end

  def at_capacity?
    event_capacity <= event_registrations.cancelled(false).count
  end

  def accepting_registrations?
    !registrations_closed? && !at_capacity? 
  end

  def as_json(options={})
    {
      :id            => id,
      :title         => title,
      :registrations => event_registrations
    }
  end

  def _post_to_twitter?;  E9::Config[:twitter_events_by_default] end
  def _post_to_facebook?; E9::Config[:facebook_events_by_default] end

  protected

    def delete_costs_if_free
      if event_is_free?
        cost_attributes(true).delete_all
      end
    end

    def assign_default_preferences
      super

      self.display_social_bookmarks = E9::Config[:event_show_social_bookmarks] if self.display_social_bookmarks.nil?
      self.display_actions          = E9::Config[:event_display_actions]       if self.display_actions.nil?
      self.display_date             = E9::Config[:event_show_date]             if self.display_date.nil?
      self.display_author_info      = E9::Config[:event_show_author_info]      if self.display_author_info.nil?
      self.display_labels           = E9::Config[:event_show_labels]           if self.display_labels.nil?
      self.allow_comments           = E9::Config[:event_allow_comments]        if self.allow_comments.nil?
    end

    def reject_record_attribute?(attrs)
      attrs.keys.member?('options') && attrs['options']['label'].blank?
    end

end
