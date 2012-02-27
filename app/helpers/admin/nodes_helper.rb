module Admin::NodesHelper
  def node_renderable_select_options(scope)
    case resource.renderable
    when Banner
      scope.order(:name).map {|b| [b.name, b.id] }
    else 
      scope.sort_by {|r| r.form_field_name.downcase }.
        map {|r| [r.form_field_name, r.id] }
    end
  end

  # 
  # descend into admin.nodes scope for different renderable types
  #
  def node_update_i18n_scope
    if resource.renderable
      :"admin.nodes.#{resource.renderable.class.model_name.collection}"
    end
  end
end
