module ImageMountsHelper
  def image_mount_tag(image_mount, options = {})
    options.symbolize_keys!

    img_options = options.slice!(:force_blank)

    if !image_mount.nil?
      img_options[:alt] = img_options.fetch(:alt) { image_mount.spec_name }

      # this is for failed forms, pre-popping
      if image_mount.new_record? && fbu = image_mount.fallback_url
        img_options['data-orig-src'] = fbu
      end

      url = image_mount.url

      if url.present?
        image_tag url, img_options
      elsif options[:force_blank]
        tag :img, img_options.merge(:src => '')
      end
    end
  end

  def image_mount_field(image_mount, options = {})
    options.merge!(:resource => image_mount)

    if options[:index]
      @image_mount_index = options[:index].to_i
      render "image_mounts/field", options
    else
      options[:index] = image_mount_index(true)

      tag_options = {}.tap do |opts|
        opts['class']      = "image-mount-wrapper"
        opts['id']         = "image-mount-wrapper-#{options[:index]}"
        opts['data-url']   = url_for(image_mount)
        opts['data-index'] = options[:index]
      end

      content_tag :div, tag_options do
        render "image_mounts/field", options
      end
    end
  end

  def image_mount_index(increment=false)
    @image_mount_index ||= 0
    @image_mount_index += 1 if increment
    @image_mount_index
  end

  def link_to_image_mount_select(image_mount, options={})
    return unless admin?

    text = e9_t(:select_image)
    url = select_images_path

    options[:class] = 'select'

    link_to text, url, options
  end

  def link_to_image_mount_crop(image_mount, options={})
    return unless image_mount.persisted?

    text = e9_t(:crop_image)
    url = url_for(image_mount)

    options[:class] = 'crop'
    options[:style] = 'display: none' if image_mount.attachment.blank?

    link_to text, url, options
  end

  def link_to_image_mount_reset(image_mount, options={})
    text = e9_t(:reset_image)

    if image_mount.persisted?
      url = reset_image_mount_url(image_mount)
    else
      url = '#'
    end

    options[:class]   = 'reset'
    options[:remote]  = true
    options[:method]  = 'delete'

    options[:style] = 'display: none' if image_mount.attachment.blank?

    link_to text, url, options
  end
end
