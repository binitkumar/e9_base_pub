class Template < ActiveRecord::Base
  include E9::Roles::Roleable
  
  validates :css_class, :format => { :with => /\A([A-z][\w-]*\s*)+\Z/, :allow_blank => true }
end
