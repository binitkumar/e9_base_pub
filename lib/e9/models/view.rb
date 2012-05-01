module E9::Models
  #
  # View or "Page".  A page including this must have a layout
  # association (TODO enforce) and can be rendered as the "current_page"
  #
  # must have layout association
  # must have title
  #
  module View
    extend ActiveSupport::Concern

    included do
      has_many :regions, :as => :view, :autosave => true, :dependent => :destroy
      validates_associated :regions
      accepts_nested_attributes_for :regions, :allow_destroy => true
    end

    ##
    # interface for rendering
    #

    def region(domid)
      if new_record? or regions.to_a.any?(&:new_record?)
        regions.to_a.detect {|p| p.domid == domid.to_s }
      else
        regions.where(:domid => domid.to_s).includes(:renderables).first
      end
    end

    def renderables
      regions.map(&:renderables).flatten
    end

    # NOTE if this is true the page must implement menu_ancestors
    def has_own_breadcrumbs?
      false
    end

    def show_home_breadcrumb?
      false
    end

    def menu_ancestors
      []
    end
    
    ##
    # interface for admin
    #

    def regions_editable_by_user(user = nil)
      return [] if user.blank?

      if new_record? or regions.to_a.any?(&:new_record?)
        region_types = RegionType.all
        regions.to_a.select do |r| 
          region_type = region_types.detect {|rt| rt.id == r.region_type_id }
          region_type && user.role.includes?(region_type.role) && (Layout === self || !region_type.layout_only)
        end
      else
        retv = regions.for_roleable(user)
        retv = retv.layout_only(false) unless Layout === self
        retv
      end
    end

    def has_region?(domid)
      !region(domid).nil?
    end

    def copy
      if respond_to?(:layout)
        copied_attributes = attributes.slice *%w(
          allow_comments
          blog_id
          body
          custom_css_classes
          display_actions
          display_author_info
          display_date
          display_labels
          display_more_info
          display_social_bookmarks
          event_capacity
          event_max_guests
          event_show_promo_code
          event_is_free
          event_registration_message
          form_html
          display_title
          editable_content
          faq_id
          forum_id
          link_text
          meta_description
          meta_keywords
          meta_title
          role
          user_id
        )

        if self.kind_of?(E9Tags::Model)
          copied_attributes.merge!(:tag_lists => self.tag_lists)
        end

        layout.prototype self.class, copied_attributes.merge({
          :title   => generate_copy_of_field(:title),
          :regions => regions.map(&:copy)
        })
      end
    end

    def reset_layout!
      change_layout(self.layout, true) if self.layout.present?
    end

    def change_layout(new_layout, allow_same_layout=false)
      begin
        if !allow_same_layout && self.layout == new_layout
          raise "You cannot change to the same layout" 
        end

        unless prototype = new_layout.prototype(self.class)
          raise "There was an error updating the layout"
        end

        self.regions.clear()
        self.regions = prototype.regions

        if respond_to?(:images)
          self.images.clear()
          self.images = prototype.images
        end

        if respond_to?(:placements)
          self.placements.clear()
          self.placements = prototype.placements
        end

        yield(self, prototype) if block_given?

        self.layout  = new_layout

        self.published = false unless valid?

        errors.clear

        save(:validate => false)
      rescue => e
        errors[:base] << e.message
        false
      end
    end

    def generate_copy_of_field(field, options = {})
      options.reverse_merge!({
        :template => "Copy of %s (%d)"
      })

      n = 0
      
      begin
        copy_of_field = options[:template] % [send(field), n += 1]
      end while !!self.class.where(field => copy_of_field).any?

      copy_of_field
    end
  end
end
