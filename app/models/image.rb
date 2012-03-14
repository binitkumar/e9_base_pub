class Image < ActiveRecord::Base
  include E9Tags::Model
  include E9::ActiveRecord::AttributeSearchable

  image_accessor :attachment

  has_many :image_mounts, :dependent => :restrict

  scope :attached, lambda {|v=true| where attached_condition(v) }
  scope :unattached, lambda { attached(false) }
  scope :search, lambda {|query| attr_like(:attachment_name, query) }

  def self.attached_condition(attached=true)
    arel_table[:attachment_uid].send(attached ? :not_eq : :eq, nil)
  end

  delegate :url, :aspect_ratio, :portrait?, :landscape?, :depth, :number_of_colours, :format, :image?, 
      :to => :attachment, :allow_nil => true

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

  def attached?
    attachment_uid.present?
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

  module DimensionCaching
    extend ActiveSupport::Concern

    included do
      class_attribute :dimension_target
      self.dimension_target = :attachment

      before_save :cache_dimensions, :if => :should_cache_dimensions?
    end

    # fall back to 0 for dimensions
    def width
      read_attribute(:width) || _target_width
    end

    def height
      read_attribute(:height) || _target_height
    end

    def dimensions
      E9::ImageSpecification::Dimensions.new(self, width, height)
    end

    def should_cache_dimensions?
      !cached_dimensions? || self.attachment_uid_changed?
    end

    def cached_dimensions?
      [ read_attribute(:width), read_attribute(:height) ].all?
    end

    protected

    def _target_width
      send(dimension_target).try(:width) || 0
    end

    def _target_height
      send(dimension_target).try(:height) || 0
    end

    def cache_dimensions
      self.width, self.height = _target_width, _target_height
    end

    def cache_dimensions!
      cache_dimensions
      save
    end
  end

  include DimensionCaching
end
