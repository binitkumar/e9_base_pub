class SlideshowAssignment < ActiveRecord::Base
  default_scope :order => "slideshow_assignments.position"
  belongs_to :slide
  belongs_to :slideshow

  acts_as_list :scope => :slideshow

  class << self
    def clear_duplicates_of(assignment)
      where(arel_table[:id].eq(assignment.id).not).
        where(:slideshow_id => assignment.slideshow_id).
        where(:slide_id => assignment.slide_id).
        delete_all
    end
  end

  after_save :clear_assignment_duplicates

  #
  # NOTE previous_slide and next_slide are NOT USED because of custom slideshows
  #      (although really the "pseudo" slideshow vs the regular slideshow through
  #      assignments could implement next/prev differently)
  #

  def previous_slide
    higher_item.try :slide
  end

  def next_slide
    lower_item.try :slide 
  end


  protected

  def clear_assignment_duplicates
    self.class.clear_duplicates_of(self)
  end


end
