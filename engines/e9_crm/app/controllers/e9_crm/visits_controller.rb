class E9Crm::VisitsController < E9Crm::ResourcesController
  defaults :resource_class => PageView, :collection_name => :page_views
  belongs_to :campaign
  include E9::Controllers::Orderable

  helper :"e9_crm/deals"

  actions :index

  # NOTE association chain is prepended to ensure parent is loaded so other
  #      before filters can use collection_path, etc.  Is there a better solution
  #      for this?
  #
  prepend_before_filter :association_chain

  before_filter :determine_title, :only => :index

  has_scope :until_time, :as => :until, :unless => 'params[:from].present?'
  has_scope :from_time, :as => :from do |controller, scope, value|
    if controller.params[:until]
      scope.for_time_range(value, controller.params[:until])
    else
      scope.from_time(value)
    end
  end

  has_scope :visits_by_contact, :type => :boolean, :default => true

  protected

  def collection
    get_collection_ivar || begin
      sel_sql = <<-SQL.sub(/\s+/, ' ')
        SUM(vbc.new_visits) new_visits,
        SUM(vbc.repeat_visits) repeat_visits
      SQL

      objects = end_of_association_chain.paginate(pagination_parameters)

      objects.class_eval do
        attr_accessor :counter

        def new_visit_count
          @counter.first && @counter.first.new_visits.to_i || 0
        end

        def repeat_visit_count
          @counter.first && @counter.first.repeat_visits.to_i || 0
        end
      end

      objects.counter = resource_class.select(sel_sql).
                          from("(#{end_of_association_chain.to_sql}) vbc")

      set_collection_ivar objects
    end
  end

  def default_ordered_dir
    'ASC'
  end

  def default_ordered_on
    'contact_name'
  end

  def add_index_breadcrumb
    add_breadcrumb! e9_t(:breadcrumb_title)
  end

  def determine_title
    @index_title = e9_t(:index_title, :parent => parent.to_s)
  end
end
