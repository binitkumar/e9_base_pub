class Attachment < ActiveRecord::Base
  scope :attached,   lambda {|bool=true| where arel_table[:file].eq(nil).send(bool ? :not : :presence) }
  scope :unattached, lambda { attached(false) }
  scope :ordered,    lambda { order(:position) }

  belongs_to :owner, :polymorphic => true

  ##
  # carrierwave
  #
  mount_uploader :file, AttachmentUploader
  delegate :url, :path, :name, :extension, :to => :file, :prefix => true
  delegate :width, :height, :format, :url, :path, :to => :file

  delegate :thumb, :to => :file, :allow_nil => true

  def should_create_thumbs?
    owner.respond_to?(:create_attachment_thumbs) && owner.create_attachment_thumbs
  end

  def has_thumb?
    thumb.present? && thumb.url =~ /\.(jpe?g|png|gif|bmp)/i
  end

  def file_type
    retv = case file_extension
    when /\.(jpe?g|png|gif|bmp)$/i
      'image'
    when /\.pdf$/i
      'pdf'
    when /\.html?$/i
      'html'
    when /\.xls$/i
      'xls'
    when /\.(docx?|rtf)$/i
      'doc'
    when /\.ppt$/i
      'ppt'
    else
      'file'
    end

    ActiveSupport::StringInquirer.new(retv)
  end

  ##
  # Acts as List impl
  #
  acts_as_list

  def scope_condition
    self.class.send(:sanitize_sql_hash_for_conditions, :owner_id => owner_id, :owner_type => owner_type)
  end

  #MAX_FORM_WIDTH = 400

  #scope :with_spec,  lambda {|i| where(:image_spec_id => i.to_param) }

  ###
  ## associations
  ##
  #belongs_to :image_spec

  ###
  ## callbacks
  ##
  #before_validation :process

  ###
  ## delegations
  ##
  #delegate :name, :base_name, :required?, :to => :image_spec, :prefix => true, :allow_nil => true

  #def default_url
    #specification && specification.respond_to?(:default_url) && specification.default_url.presence
  #end

  ## TODO modulize image_specification stuff
  ##
  #def specification
    #image_spec || (owner.respond_to?(:specified_dimensions) ? owner : nil)
  #end

  #def specification_name
    #image_spec_name
  #end

  #def has_specification?
    #specification.present?
  #end

  #delegate :specified_dimensions?, :specified_dimensions, :satisfied_by?, :to => :specification, :allow_nil => true

  #def satisfies_specification?
    #return true if !has_specification? || specification.satisfied_by?(self)

    #errors.add(:file, :image_spec, {
      #:specification_name => specification_name, 
      #:specified_dimensions => specified_dimensions
    #})

    #false
  #end

  ##
  ##
  ##

  #attr_accessor :operation, :proc_args

  #def dimensions
    #[width, height]
  #end

  #def to_json(options = {})
    #super(options.merge(:only => :id, :methods => [:url, :width, :height]))
  #end

  #def is_attached?
    #owner.present?
  #end

  #def skip_auto_resize?
    #operation.present?
  #end

  #protected

  #def process
    #unless operation.blank?
      #case operation.to_sym
      #when :crop; self.crop!
      #when :copy; self.copy!
      #end
    #end
    #proc_args, operation = nil, nil

    #return false if errors.any?
  #end

  #def copy!
    #raise unless proc_args.kind_of?(Hash)
    #model, mount, id = proc_args.values_at(:model, :mount, :id)

    #record = model.classify.constantize.find(id)
    #raise unless record.respond_to?(mount)

    #mount = record.send(mount)
    #raise unless mount && mount.present?

    #self.file = mount
  #rescue => e
    #Rails.logger.error(e)
    #errors.add(:file, :processing_error, :operation => "Copy")
  #end

  ###
  ## accepts: x, y, width, height, scale ratio (optional)
  ##
  #def crop!
    #if proc_args.blank? || !(4..5).include?(proc_args.length)
      #errors.add(:file, :crop_arguments)
    #else
      #begin 
        #proc_args.map!(&:to_f)

        ## the crop values are based on the original size, so crop first ...
        #file.crop!(*proc_args[0,4])

        ## ... then scale if the arg was passed
        #file.scale!(proc_args.last) if proc_args.length == 5
      #rescue => e
        #Rails.logger.info("Crop error: #{e.message}")
        #errors.add(:file, :processing_error, :operation => "Crop")
      #end
    #end
  #end
end
