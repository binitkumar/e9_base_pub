if contact = Contact.find_by_first_name("Conrad")
  contact.instant_messaging_handle_attributes.clear
  contact.phone_number_attributes.clear
  contact.website_attributes.clear
  contact.address_attributes.clear
end
