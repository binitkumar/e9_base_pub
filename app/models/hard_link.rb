class HardLink < Menu
  validates :name, :presence => true
  validates :href, :presence => { :allow_blank => true }, :link => true
end
