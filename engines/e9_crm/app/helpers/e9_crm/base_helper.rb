module E9Crm::BaseHelper

  ##
  # Field maps
  #
  
  def records_table_field_map(options = {})
    options.symbolize_keys!
    options.reverse_merge!(:class_name => resource_class.name.underscore)

    base_map = {
      :fields => { :id => nil },
      :links => lambda {|r| [link_to_edit_resource(r), link_to_destroy_resource(r)] }
    }

    method_name = "records_table_field_map_for_#{options[:class_name]}"

    if respond_to?(method_name)
      base_map.merge! send(method_name)
    end

    base_map
  end

  def sortable_controller?
    @_sortable_controller ||= controller.class.ancestors.member?(E9::Controllers::Sortable)
  end

  def contacts_by_roles(*roles)
    User.includes(:contact).for_roles(*roles.flatten).all.
      map(&:contact).
      uniq.
      compact.
      sort_by {|c| c.name.upcase }
  end

  def privileged_roles
    E9::Roles.list.map(&:role).select {|r| r > 'user' && r < 'e9_user' }
  end

  def administrator_roles
    E9::Roles.list.map(&:role).select {|r| r >= 'administrator' && r < 'e9_user' }
  end

  def privileged_contacts
    @_privileged_contacts ||= contacts_by_roles(privileged_roles)
  end

  def administrator_contacts
    @_administrator_contacts ||= contacts_by_roles(administrator_roles)
  end
end
