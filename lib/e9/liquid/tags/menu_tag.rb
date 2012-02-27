module E9::Liquid::Tags
  class MenuTag < Base
    FIND_ATTRIBUTES = [:name, :identifier, :id].freeze
    MENU_OPTIONS    = [:display_root, :truncate, :truncate_all].freeze

    class << self
      def title
        "Menu"
      end

      def description
        "Tag to render a menu"
      end

      def tag_name
        "menu"
      end
    end

    def render!
      if menu = Menu.where(@attributes.slice(*FIND_ATTRIBUTES)).first
        is_root = menu.root?
        
        # ignore subnav if this menu is not root
        if E9.true_value?(@attributes.delete(:subnav)) && is_root

          # but if it is, look for a child branch containing the current page, make that the active menu ...
          if submenu = menu.child_with_descendant_for_page(controller_send(:current_page))
            menu = submenu

            # ... and set display_root to true
            @attributes[:display_root] = true
          end

        # otherwise if not root, assume display root is true
        elsif !is_root
          @attributes[:display_root] = true
        end

        view_send(:render_menu, menu, @attributes.slice(*MENU_OPTIONS))
      end
    end
  end

  Liquid::Template.register_tag(MenuTag.tag_name, MenuTag)
end
