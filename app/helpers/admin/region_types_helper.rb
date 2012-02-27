module Admin::RegionTypesHelper
  def region_type_select_array_for_renderable_and_user(renderable, user)
    region_types_addable_to_renderable_by_user(renderable, user).map {|r| [r.name, r.id] }.unshift [e9_t(:blank_select_option), nil]
  end

  def region_types_addable_to_renderable_by_user(renderable, user)
    # returns the region types the user can touch, minus the region_types already on the renderable
    (RegionType.for_roleable(user) - renderable.region_types).sort_by(&:name)
  end
end
