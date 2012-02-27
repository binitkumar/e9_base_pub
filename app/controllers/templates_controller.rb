class TemplatesController < ApplicationController
  TAGMAP = Hash[*Liquid::Template.tags.select{|h,k| k.parent == E9::Liquid::Tags }.flatten].freeze
  
  before_filter :prepare_templates, :only => :index

  # js template renders the template list for TinyMCE
  # TODO can we do this with JSON rather than a template?  Would it be cleaner?  Does it matter?
  def index
  end

  def show
    unless tag = TAGMAP[params[:id]]
      render_404
    else
      # in the case of these simple tags it just returns the liquid tag itself to be evaluated later
      # e.g. {% some_tag %} but it could just as well return a real template
      respond_to do |format|
        format.html { render :inline => tag.to_s }
      end
    end
  end

  protected

  def prepare_templates
    selected_tags = TAGMAP.keys & Array.wrap((params[:tags] || []))

    @templates = TAGMAP.values_at(*selected_tags).map do |tag_class|
      [tag_class.title, "/templates/#{tag_class.tag_name}.html", tag_class.description]
    end
  end

end
