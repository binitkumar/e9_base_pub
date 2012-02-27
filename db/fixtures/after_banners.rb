banner = Banner.first

if banner.images.attached.empty?
  banner.images << Image.create!(
    :file => File.open("#{Rails.root}/public/images/site/banner.jpg")
  )
end
