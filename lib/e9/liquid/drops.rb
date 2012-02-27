module E9::Liquid::Drops
  class Base < ::Liquid::Drop
    class << self
      def source_methods(*methods)
        options = methods.extract_options!
        options[:method] ||= :method

        methods.flatten.each do |m|
          define_method(m) do
            send :"source_#{options[:method]}", m
          end
        end
      end

      def date_methods(*methods)
        source_methods *methods, :method => :localize
      end
    end

    attr_reader :object

    def initialize(object = nil)
      @object = object 
    end

    def content_type
      @object.class.model_name.human rescue nil
    end

    def updated_at
      source_localize :updated_at
    end

    def created_at
      source_localize :created_at
    end

    protected

    def source_method(m)
      @object.try(:send, m)
    end

    def source_localize(m)
      I18n.l source_method(m)
    end

    #
    # NOTE in mail the "controller" is the mailer, for url_for purposes, but this will cause
    #      unexpected behavior if the liquid tries to do other things that a controller can
    #      do but a mailer cannot
    #
    def controller;             @context.registers[:controller] end
    def controller_send(*args); controller.try(:send, *args) || '' end
  end

  class Feed < Base
    class_inheritable_accessor :valid_options
    self.valid_options = []

    attr_writer :feed_options
    def feed_options; @feed_options ||= {} end

    attr_reader :scope

    def process_content_type(scope, opts = nil)
      # if content_type is blank or includes "all"
      if !opts.blank? && !opts.any? {|t| t =~ /\ball\b/i }
        types = map_content_types(opts)
        feed_options[:content_type] = types
        scope.of_type(types)
      else
        scope
      end
    end

    def process_role(scope, opts = nil)
      role  = [@context ? @context['user'].role : 'guest', 'user'.role].max
      roles = opts ? opts.map(&:downcase) & role.roles : role.roles

      scope.for_roles(roles)
    end

    private

    # maps user supplied model names to app model name equivs
    def map_content_types(types)
      @_content_type_map ||= Hash.new {|h, k| k }.tap do |map|
        map[:page] = 'user_page'
        map[:faq]  = 'question'
      end

      types.map {|t| @_content_type_map[t.to_sym] }
    end
  end

  class Linkable < Base
    def path
      object.path if object.respond_to?(:to_polymorphic_args)
    end

    def url
      object.url if object.respond_to?(:to_polymorphic_args)
    end
  end
end

Dir["#{File.dirname(__FILE__)}/drops/*.rb"].each {|file| require file }
