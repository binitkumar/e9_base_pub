class NoCampaign < Campaign
  CODE = 'Code1'
  NAME = 'Campaign1'

  before_validation do |record|
    record.code = CODE
    record.name = NAME
  end

  def cost
    0
  end
end
