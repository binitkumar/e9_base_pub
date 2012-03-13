require 'rails/all'

ActiveRecord::Base.send(:include, E9::HtmlSafeColumns)
ActiveRecord::Base.send(:include, E9::ActiveRecord::Anchorable)
ActiveRecord::Base.send(:include, E9::ActiveRecord::Scopes)
ActiveRecord::Base.send(:include, E9::Models::RecordSequence)
ActiveRecord::Base.send(:include, E9::Models::ImageMounting)

#
# Hack to allow passing options for polymorphic routes resolved through url_for
#
# polymorphic_url accepts options, but the url_for helper methods only ever pass
# one, leaving no way to slip url parameter options into polymorphic routes
# generated through link_to
#
module ActionDispatch::Routing::PolymorphicRoutes
  unless instance_methods.map(&:to_sym).include?(:polymorphic_url_with_option_extraction)
    def polymorphic_url_with_option_extraction(record_or_hash_or_array, options = {})
      if Array === record_or_hash_or_array && Hash === record_or_hash_or_array.last
        options.merge! record_or_hash_or_array.pop
      end

      polymorphic_url_without_option_extraction(record_or_hash_or_array, options)
    end
    alias_method_chain :polymorphic_url, :option_extraction
  end
end

# because having a 5mb string dump in your stacktrace isn't so nice
ActionDispatch::Routing::RouteSet.class_eval do
  def inspect; to_s end
end

class ActiveRecord::Base
  # This is for delayed job?
  def display_name
    self.class.name
  end

  # override read_attribute_for_validation to allow :base errors to be added via Errors#add
  #
  def read_attribute_for_validation(attr)
    super
  rescue NoMethodError => e
    raise e unless attr == :base
  end

  class << self
    def html_tokenizer
      lambda {|str| str.blank? ? '' : CGI.unescapeHTML(HTML::FullSanitizer.new.sanitize(str)) }
    end
  end
end


#
# Fragile-ish hack to overcome static international date parsing in ruby 1.9.
#
# It simply examines the default I18n translation for a date string and if it
# finds that %m/%d is present (American date style) it notes that it should
# reverse the pattern when parsing, effectively changing mm/dd/yyyy to
# dd/mm/yyyy (which is a format Date._parse expects)
#
# TimeZone.parse uses Date._parse as well so this solves DateTime and Time
# parsing as well.
#
# This is fragile for (at least) two reasons.
#
# 1. It doesn't allow for much flexibility in the translation format, e.g.
#    this won't fix mm-dd-yyyy presently.
#
# 2. This only examines the default date tranlation, not time, so for example
#    if your default date is mm/dd/yyyy and your default time for some reason
#    is the reverse, dd/mm/yyyy, this patch will break time inputs
#    (reversing them back to american style).
#
require 'date'

class Date
  class << self
    DATE_SWAP_REGEX = /(\d\d?)\/(\d\d?)\//

    alias_method :_parse_default, :_parse

    def _parse(*args)
      if !instance_variable_defined?(:@_should_americanize_date)
        @_should_americanize_date = !(I18n.t('date.formats.default') =~ /%m\/%d/).nil? rescue false
      end

      if @_should_americanize_date && String === args.first
        _parse_default(*args.unshift(args.shift.sub(DATE_SWAP_REGEX, '\2/\1/')))
      else
        _parse_default(*args)
      end
    end
  end
end

#
# Hack... hopefully this will be fixed in Rails
#
# has_many_through association's destroy method calls delete_all, meaning the destroy hooks
# aren't executed when associations are destroyed in certain situations.
#
# The case I need this to happen in is:
#
# some_record.some_association_ids # [1,2,3]
# some_record.some_association_ids = [1] # 2, and 3 should be destroyed, not deleted
#
# the purpose in this particular case is so counter_cache can be updated on the parent
#
#ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
  #def delete_records(records)
    #klass = @reflection.through_reflection.klass
    #records.each do |associate|
      #klass.destroy_all(construct_join_attributes(associate))
    #end
  #end
#end

class E9::FormBuilder < ::ActionView::Helpers::FormBuilder

  def submit_with_object_name(*args)
    old_object_name, object_name = object_name, args.shift
    submit(*args)
  ensure
    object_name = old_object_name
  end

  #
  # Override text_field and text_area to automatically add maxlength.
  #
  %w(text_field text_area).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})  # def text_field(method, options = {})

        # Looks for a length validator on the instance, by its class.  This really feels
        # wrong but I don't know a better way as validations are just thrown into callbacks
        # without any reference. #_validators just returns EVERY validator in the app, not 
        # for each class, which would be useful.
        #
        if @object.respond_to?(:_validate_callbacks) && @object._validate_callbacks.present?
          begin
            if length_validator = @object._validate_callbacks.detect {|n| n.raw_filter.is_a?(ActiveModel::Validations::LengthValidator) && n.raw_filter.attributes.include?(method.to_sym) }
              validation_opts = length_validator.raw_filter.options
              tokenizer, maximum = validation_opts.values_at(:tokenizer, :maximum)

              # on top of the above kludginess it's necessary to figure out if the tokenizer is doing
              # any processing on the string.  The only tokenizer used in the app is an HTML stripper,
              # so this will test a simple HTML string to see if it gets stripped.  If not... we're
              # assuming the tokenizer is simply the default string split
              #
              if maximum && tokenizer.nil? or tokenizer.call("<br/>").length == 5
                options[:maxlength] = maximum
              end
            end
          
          # fail silently if there is some unforeseen issue
          rescue => e
            #Rails.logger.error("Error in form helper override: " << e.message)
            raise e
          end
        end

        @template.send(                      #   @template.send(
          #{selector.inspect},               #     "text_field",
          @object_name,                      #     @object_name,
          method,                            #     method,
          objectify_options(options))        #     objectify_options(options))
      end
    RUBY_EVAL
  end
end

ActionView::Base.default_form_builder = E9::FormBuilder


module ActionView::Helpers::FormOptionsHelper
  # Return select and option tags for the given object and method, using state_options_for_select to generate the list of option tags.
  def state_select(object, method, country = nil, options = {}, html_options = {})
    country ||= object.country || 'US'
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_state_select_tag(country, options, html_options)
  end
  
  def state_options_for_select(selected = nil, country = 'US')
    options_for_select(US_STATES, selected)
  end
  
  private
  
  US_STATES=["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "Washington D.C.", "West Virginia", "Wisconsin", "Wyoming"] unless const_defined?("US_STATES")
end

class ActionView::Helpers::InstanceTag
  def to_state_select_tag(country, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    content_tag("select", add_options(state_options_for_select(selected_value, country), options, value), html_options)
  end
end

class ActionView::Helpers::FormBuilder
  def state_select(method, country = 'US', options = {}, html_options = {})
    @template.state_select(@object_name, method, country, options.merge(:object => @object), html_options)
  end
end 


# 99/100 times we want humanize to titleize, so let's just do that.
#
# NOTE this unless constuct is because of a current architecture problem with e9/e9_base, which causes
# the initializers to run twice (both as an engine and an app).  This is only a problem for generating
# migrations, etc, but it is a problem.
unless ''.respond_to?(:humanize_without_titleize)
  class String
    alias :humanize_without_titleize :humanize

    def humanize
      humanize_without_titleize.titleize
    end
  end
end

module ActionView::Rendering 
  alias_method :_render_template_original, :_render_template
  def _render_template(*args)
    rendered_templates << args.first
    _render_template_original(*args)
  end

  def rendered_templates
    @_rendered_templates ||= []
  end
end
