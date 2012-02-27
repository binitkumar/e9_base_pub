class Image < ActiveRecord::Base
  include E9Tags::Model

  image_accessor :attachment

  has_many :image_mounts, :dependent => :restrict

  scope :attached, lambda {|v=true| where attached_condition(v) }
  scope :unattached, lambda { attached(false) }

  def self.attached_condition(attached=true)
    arel_table[:attachment_uid].send(attached ? :not_eq : :eq, nil)
  end

  delegate :url, :aspect_ratio, :portrait?, :landscape?, :depth, :number_of_colours, :format, :image?, 
      :to => :attachment, :allow_nil => true

  before_save :cache_dimensions, :if => 'attachment_uid_changed?'

  def width() read_attribute(:width) || attachment.try(:width) || 0 end
  def height() read_attribute(:height) || attachment.try(:height) || 0 end

  # Instructions are in the form:
  #
  #     {
  #       '0' => [:proc_method, *proc_args],
  #       '1' => [:proc_method, *proc_args]
  #     }
  #
  def process(instructions)
    return nil unless attachment.present?

    (instructions || {}).dup.sort.inject(attachment.dup) do |processed, row|
      index, step = row
      processed.process(*step)
    end
  end

  def dimensions
    Dimensions.new(width, height)
  end

  def as_json(options={})
    {
      :id => id,
      :url => url,
      :width => width,
      :height => height
    }
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  # A string of file extensions acceptable for the uploader.
  # (passed to uploadify)
  #
  def file_ext(delimiter=';')
    (extension_white_list || []).map {|ext| "*.#{ext}" }.join(delimiter)
  end

  # Description of file types acceptable for the uploader
  # (passed to uploadify)
  #
  def file_desc
    "Images (#{file_ext(',')})"
  end

  def image_tags
    tag_list_on('images__h__').sort {|a, b| a.upcase <=> b.upcase }
  end

  def image_tags=(tags)
    self.set_tag_list_on('images__h__', tags)
  end

  protected

    def cache_dimensions
      self.width  = attachment.try(:width)
      self.height = attachment.try(:height)
    end

  class Dimensions < Array
    def initialize(width, height)
      super [width, height]
    end

    alias :width :first
    alias :height :last

    def to_s
      "#{width}x#{height}"
    end
  end
end
