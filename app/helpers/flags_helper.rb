module FlagsHelper
  def flag_link(flaggable)
    action, options = nil, {}

    options[:class] = 'action-link'

    if flaggable.flagged?
      action           = :remove_flag
      options[:method] = :delete
      options[:class]  << ' remove-flag'
    else
      action           = :add_flag
      options[:method] = :post
      options[:class]  << ' add-flag'
    end

    link_to e9_t(action, :scope => :flags), [flaggable, :flag], options.merge(:remote => true)
  end

end
