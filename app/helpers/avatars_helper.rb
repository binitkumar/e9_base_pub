module AvatarsHelper

  # NOTE avatar_link_for is just an image, for now
  def avatar_link_for(user, options = {})
    avatar_image_for(user, options)
  end

  def avatar_image_for(user, options = {})
    alt  = user ? e9_t(:avatar_link_alt, :username => user.username) : e9_t(:default_avatar_link_alt)
    user ||= User.new :username => e9_t(:anonymous_username)
    options[:class] = [options[:class], 'avatar'].compact.join(' ')
    image_mount_tag user.avatar, options.reverse_merge(:alt => alt)
  end

  def default_avatar_image_tag(options = {})
    avatar_image_for(nil, options)
  end
end
