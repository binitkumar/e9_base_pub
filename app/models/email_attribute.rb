class EmailAttribute < RecordAttribute
  validates :value, :email => true
end
