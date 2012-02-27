class Placeholder < Renderable
  # A place holder for data.
  #
  # Behaves much like an ImageSpec, but for text blocks.
  #
  has_many :placements, :foreign_key => :associated_id

  def width
    # assume string width
    read_attribute(:width) || 255
  end

  def self.renderable?
    false
  end
end
