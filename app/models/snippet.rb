class Snippet < Renderable
  validates :template, :presence => true, :liquid => true

  attr_writer :set_revert_template
  before_save :set_revert_template_if_necessary

  def formatter=(v)
    self.width = v
  end

  def formatter
    Formatter.new(width)
  end

  def set_revert_template
    !!@set_revert_template && @set_revert_template != "false"
  end

  def revert_template!
    if revert_template.blank?
      self.errors.add(:revert_template, :empty)
    else
      self.template = revert_template
      save(:validate => false)
    end
  end

  def revert_template?
    read_attribute(:revert_template).present?
  end

  # ensure template never sends nil to the view
  def template;
    read_attribute(:template) || ''
  end

  def clone
    super.tap {|snippet| snippet.revert_template = nil }
  end

  protected

  def set_revert_template_if_necessary
    self.revert_template = self.template if set_revert_template
  end

  class Formatter < ActiveSupport::StringInquirer
    Options = %w(tinymce text markdown)

    def initialize(index)
      index ||= 0
      super(Options[index] || '')
    end
  end
end
