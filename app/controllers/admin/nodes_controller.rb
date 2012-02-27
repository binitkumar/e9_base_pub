class Admin::NodesController < Admin::ResourceController
  layout false
  skip_after_filter :flash_to_headers

  # rerender update on both success and failure
  def update
    update! do |format|
      format.js 
    end
  end

  protected

  def resource
    @node ||= super.tap do |node|
      @node_renderable_option_scope = node.renderable.present? && node.renderable.class.node_options(node, :user => current_user)

      if @node_renderable_option_scope.blank?
        node.errors.add(:renderable_id, :no_options)
      end
    end
  end
end
