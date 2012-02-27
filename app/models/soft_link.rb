class SoftLink < Menu

  validates :link_id, :presence => true
  validates :name, :presence => { :unless => lambda {|link| link.delegate_title_to_link? } }

  delegate :href, :linkable, :to => :link, :allow_nil => true

  def name
    link_text
  end

  def link_text
    if delegate_title_to_link? && !link.try(:title).blank?
      link.title
    else
      # TODO improve the html_safe_column hack so this is not necessary
      ActiveSupport::SafeBuffer.new(read_attribute(:name).to_s)
    end
  end

end
