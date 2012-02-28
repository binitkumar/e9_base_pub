banner = Banner.first

if banner.images.attached.empty?
  img = Image.create!(:attachment => File.open("#{Rails.root}/public/images/site/banner.jpg"))
  banner.images.create(:image => img)
end
