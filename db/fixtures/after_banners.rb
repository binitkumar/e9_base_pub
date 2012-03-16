banner = Banner.first
path   = "#{Rails.root}/static/images/site/banner.jpg"

if banner.images.attached.empty? && File.exist?(path)
  img = Image.create!(:attachment => File.open(path))
  banner.images.create(:image => img)
end
