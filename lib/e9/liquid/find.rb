module E9::Liquid::Find
  def liquid_scope
    scoped
  end

  def liquid_find(context=nil, args={})
    scope = liquid_scope

    roles = args.delete(:roles)
    if scope.respond_to?(:for_roles)
      role = [context ? context['user'].role : 'guest', 'user'.role].max
      roles = roles.present? ? roles.map(&:downcase) & role.roles : role.roles
      scope = scope.for_roles(roles)
    end

    if limit = args.delete(:limit)
      scope = scope.limit(limit)
    end

    scope.all
  end
end
