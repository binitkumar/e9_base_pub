class Hit < ActiveRecord::Base
  DEFAULT_LIMIT = 10

  belongs_to :hittable, :polymorphic => true

  before_create :set_created_date

  scope :on_type, lambda {|n| where(:hittable_type => n) }

  class << self
    # TODO THIS IS NOT USED! Look at top in content_view
    def top_with_hits(hittable, opts = {})
      hittable = find_hittable_class(hittable) || ContentView
      
      take = opts.delete(:limit) || E9::Config[:feed_records]

      hittable_table = hittable.base_class.arel_table
      hits_table     = arel_table

      if hittable_table[:type]
        select_str = "hits.*, (SELECT COUNT(*) from hits as hits2 where hits2.hittable_id = hits.hittable_id AND hits2.hittable_type = hits.hittable_type and hits2.created_date = hits.created_date) as count"
      else
        select_str = "hits.*, (SELECT COUNT(*) from hits as hits2 where hits2.hittable_id = hits.hittable_id AND hits2.created_date = hits.created_date) as count"
      end

      hits = select(select_str).
                from("hits, #{hittable_table.name}").                 
                where(hits_table[:hittable_id].eq(hittable_table[:id])).
                where(hits_table[:hittable_type].eq(hittable.base_class.model_name)).
                group(hits_table[:hittable_id]).
                order('hits.created_date DESC, count DESC').
                limit(take)

      # if the hittable class is not the base class, add the condition, e.g. looking specifically for BlogPosts
      if hittable != hittable.base_class
        hits = hits.where(hittable_table[:type].eq(hittable.model_name))
      end

      # filter out roles above user if the hittable table has a role column
      if hittable_table[:role]
        hits = hits.where(hittable_table[:role].in('user'.roles))
      end

      hits = hits.all

      unless hits.empty?
        ids = hits.map(&:hittable_id)
        unsorted = hittable.base_class.find(ids, hittable.hittable_find_options)
        sorted = hits.inject([]) do |res, hit| 
          hittable = unsorted.detect {|u| u.id == hit.hittable_id }
          hittable.instance_variable_set('@hit', hit)
          hittable.instance_eval('def hit; @hit end')

          res << hittable
        end
        sorted.zip(hits)
      else
        []
      end
    end

    def top(hittable, opts = {})
      top_with_hits(hittable, opts).map(&:first)
    end
    
    def find_hittable_class(hittable)
      case hittable
        when Class
          if hittable.respond_to?(:hittable_find_options)
            hittable
          end
        when String, Symbol
          begin
            if (klass = hittable.to_s.classify.constantize) && klass.respond_to?(:hittable_find_options)
              klass
            end
          rescue
          end
      end
    end
    protected :find_hittable_class
  end

  protected


  def set_created_date
    self.created_date ||= Date.today
  end


end
