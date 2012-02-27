module Hittable

  def increment_hits!
    attrs = {}.tap do |a|
      if hit_date != Date.today
        a[:hit_count] = 1
        a[:hit_date] = Date.today
      else
        a[:hit_count] = (hit_count || 0) + 1
      end
    end

    self.class.update_all(attrs, self.class.primary_key => id) == 1
  end
end
