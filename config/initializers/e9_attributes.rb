require 'e9_base'
require 'e9_attributes'

Rails.application.config.after_initialize do
  attributes = [
    :emails, 
    :instant_messaging_handles, 
    :phone_numbers,
    :schools,
    :websites,
    :addresses
  ]

  User.has_record_attributes(attributes)
  MenuOption.keys |= attributes.map {|attr| attr.to_s.titleize.singularize }

  module E9AttributesModelController 
    extend ActiveSupport::Concern

    included do
      skip_before_filter :authenticate_user!, :filter_access_filter, :only => :templates
      skip_after_filter :track_page_view, :only => :templates
      before_filter :build_resource, :only => :templates
    end

    def templates
      render RecordAttribute::TEMPLATES
    end
  end

  ProfilesController.send(:include, E9AttributesModelController)
  EventsController.send(:include, E9AttributesModelController)

  User.send(:include, Module.new {
    extend ActiveSupport::Concern

    included do
      class_inheritable_accessor :searchable_columns
      self.searchable_columns = [:first_name, :last_name, :username, :email, :company, :title]

      # override search to do attributes
      scope :search, lambda {|query|
        rat          = RecordAttribute.arel_table

        includes(:record_attributes)
          .where(any_attrs_like_scope_conditions(*(searchable_columns + [query]))
            .or(rat[:value].matches("%#{query}%")))
      }
    end
  })
end
