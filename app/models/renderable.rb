class Renderable < ActiveRecord::Base
  include E9::Roles::Roleable
  include E9::ActiveRecord::STI

  self.default_role = 'administrator'.role

  has_many :nodes, :dependent => :restrict
  has_many :regions, :through => :nodes

  has_and_belongs_to_many :region_types

  validates :name, :unless     => proc {|s| s.system? },
                   :presence   => true, 
                   :uniqueness => { :case_sensitive => false },
                   :length     => { :maximum => 50 } 

  scope :for_region, lambda {|region, opts = {}| 
    join_table = Arel::Table.new(:region_types_renderables)

    _scope = joins(:region_types).where(join_table[:region_type_id].eq(region.region_type_id))

    # this :all means don't exclude renderables already in the region.
    # it works.. but I'm avoiding it until a better solution.
    # it was added for snippet quick change function so the options
    # could include the node's current renderable, but instead I'm shifting
    # it in afterwards in the helper
    unless opts[:all] || (ids = region.renderable_ids).empty?
      _scope = _scope.where(arel_table[primary_key].in(ids).not)
    end

    _scope
  }

  scope :image_specs, lambda { of_type(:image_spec) }
  scope :partials,    lambda { of_type(:partial) }
  scope :snippets,    lambda { of_type(:snippet) }

  class << self
    def renderable?
      true
    end

    def descendants_utilizing_node_data
      [Placeholder]
    end

    ##
    # The scope that this class should return for the select array of Renderables
    # for swapping nodes.  This is not a scope because it returns elements outside
    # the class, BUT IT MUST RETURN A SCOPE
    #
    def node_options(node, opts = {})
      Renderable.for_region(node.region).not_of_type(:banner).for_roleable(opts[:user])
    end
  end

  def form_field_name
    "#{self.class.model_name.human}: #{name}"
  end
  
  def has_template?
    template.present?
  end

  def clone
    super.tap do |renderable|
      renderable.name = generate_copy_name
      renderable.region_type_ids = region_type_ids
    end
  end

  #
  # The layouts this renderable's regions are part of, optionally further filetered by a block
  #
  def layouts
    regions.map(&:view).select do |view| 
      view.is_a?(Layout) && !block_given? or yield(view)
    end
  end

  module Widget
    extend ActiveSupport::Concern
    include E9::ActiveRecord::InheritableOptions

    included do
      belongs_to :widget_template, :foreign_key => :template_id

      self.options_parameters = [
        :sort, 
        :reverse, 
        :limit, 
        :tags, 
        :context,
        :forum_id,
        :slideshow_id,
        :content_id,
        :blog_id,
        :header_text
      ]

      class_inheritable_accessor :tag_name
      self.tag_name = 'widget'
    end

    def forums; (ids = options.forum_id) ? Forum.find_all_by_id(ids) : [] end
    def slideshows; (ids = options.slideshow_id) ? Slideshow.find_all_by_id(ids) : [] end
    def contents; (ids = options.content_id) ? ContentView.find_all_by_id(ids) : [] end
    def blogs; (ids = options.blog_id) ? Blog.find_all_by_id(ids) : [] end

    def compile
      ''.tap do |code|
        code << "<div class=\"renderable-body\">"
          code << "{% #{tag_name} "
          code << options.map {|h, k| k.presence && "#{h}[#{k.respond_to?(:join) ? k.join('|') : k}]" }.compact.join(' ')
          code << ' %}'

          if widget_template.present?
            code.sub! '%', '% for record in'
            code << "\n" << (widget_template.body || '') << "\n"
            code << "{% endfor %}"
          end
        code << '</div>'

        if options.header_text.present?
          code.sub! /^/, "<div class=\"renderable-header\">#{options.header_text}</div>"
        end

        wrapper = '<div'
        if widget_template.present?
          css_class = widget_template.respond_to?(:css_class) && widget_template.css_class.presence || "template-#{widget_template.id}"
          wrapper << " class=\"#{css_class}\""
        end
        wrapper << '>'

        code.sub! /^/, wrapper
        code << '</div>'
      end
    end

    alias :template :compile
  end

  protected

  def generate_copy_name(name_template = "Copy of %s (%d)")
    n = 1
    begin
      copy_name = name_template % [name, n]
      n += 1
    end while !!self.class.find_by_name(copy_name)

    copy_name
  end
end
