class Attachment < ActiveRecord::Base
  include E9Tags::Model
  include E9::ActiveRecord::AttributeSearchable

  scope :attached,   lambda {|bool=true| where arel_table[:file].eq(nil).send(bool ? :not : :presence) }
  scope :unattached, lambda { attached(false) }
  scope :ordered,    lambda { order(:position) }
  scope :search,     lambda {|query| attr_like(:file, query) }

  belongs_to :owner, :polymorphic => true

  ##
  # carrierwave
  #
  mount_uploader :file, AttachmentUploader
  delegate :url, :path, :name, :extension, :to => :file, :prefix => true
  delegate :width, :height, :format, :url, :path, :to => :file

  delegate :thumb, :to => :file, :allow_nil => true

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

  def file_tags
    tag_list_on('files__h__').sort {|a, b| a.upcase <=> b.upcase }
  end

  def file_tags=(tags)
    self.set_tag_list_on('files__h__', tags)
  end

  ##
  # Acts as List impl
  #
  acts_as_list

  def scope_condition
    self.class.send(:sanitize_sql_hash_for_conditions, :owner_id => owner_id, :owner_type => owner_type)
  end
end
