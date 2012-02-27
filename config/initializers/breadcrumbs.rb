require 'breadcrumbs_on_rails'

ActionController::Base.send :include, BreadcrumbsOnRails::ControllerMixin

class UListBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    return '' if @elements.blank?

    @context.content_tag(:ul, :class => :breadcrumbs) do
      ''.html_safe.tap do |html|
        @elements[0..-2].each do |element|
          html.safe_concat render_element(element)
        end
        html.safe_concat render_element(@elements[-1], true)
      end
    end
  end

  def render_element(element, last = false)
    "<li #{' class="last"' if last }>#{!last ? @context.link_to(compute_name(element), compute_path(element)) : compute_name(element)}</li>"
  end

  protected

  def compute_name(element)
    name = case element.name
           when Proc
             element.name.call(@context)
           else
             element.name.to_s
           end

    if should_truncate?
      @context.send(:truncate, name, :length => 25)
    else
      name
    end
  end

  def should_truncate?
    @_should_truncate = (request = @context.send(:request)) && !!(request.path =~ /^\/(?!admin\/)/) if @_should_truncate.nil?
    @_should_truncate
  end
end
