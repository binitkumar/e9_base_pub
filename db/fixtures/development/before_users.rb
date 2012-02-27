if user = User.find_by_email("conrad@e9digital.com")
  user.instant_messaging_handle_attributes.clear
  user.phone_number_attributes.clear
  user.website_attributes.clear
  user.address_attributes.clear
  user.school_attributes.clear
end

if user = User.find_by_email("conrad.strabone@gmail.com")
  user.instant_messaging_handle_attributes.clear
  user.phone_number_attributes.clear
  user.website_attributes.clear
  user.address_attributes.clear
  user.school_attributes.clear
end
