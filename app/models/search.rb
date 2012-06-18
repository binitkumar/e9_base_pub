class Search < ActiveRecord::Base
  # Searchables = [BlogPost, UserPage, Event, Slide, Topic, Comment, Question]
  Searchables = [UserPage, BlogPost]

  belongs_to :user
  before_create :update_counts

  def search(search_type_string = nil)
    @_results_by_class ||= _do_search(search_type_string)
  end
  alias :results_by_class :search

  def results
    results_by_class.map {|a, b| b }.flatten
  end

  def results_by_date
    results.sort_by(&:rss_date).reverse
  end

  def empty?
    results.empty?
  end

  def general_search?
    search_type.nil?
  end

  def title
    I18n.t(:"e9.search.search_results_title", :query => query)
  end

  include E9::Feedable
  def rss_title; title end
  def rss_description; rss_title end

  protected

  def opts
    {}.tap do |options|
      if self.read_attribute(:role)
        options[:roles] = self.role.roles
      end
    end
  end

  def update_counts
    # results_by_class returns scopes, which should be #count(ed) for the full results (not paginated)
    self.results_count = self.results_by_class.inject(0) {|mem, result| mem + result[1].count }

    # increment to search count
    self.search_count  = self.class.where(:query => query).count + 1
  end

  private

  #
  # returns an array of [Class, Class.search(query)]
  #
  def _do_search(search_type_string)
    _search_classes(search_type_string).inject([]) do |set, klass|
      set << [klass, klass.recent.search(self.query, opts)]
    end.select {|klass, results| !results.empty? }
  end

  def _search_classes(search_type_string = nil)
    str = search_type_string || search_type

    if str.nil?
      Searchables
    else
      str.split(/,/).map {|klass|
        klass.classify.constantize rescue nil
      }.compact & Searchables
    end.uniq
  end
end
