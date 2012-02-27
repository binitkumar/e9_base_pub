require 'spec_helper'

describe Newsletter do
  before { @email = Factory(:newsletter) }
  it 'should update status when sending' do
    proc { @email.send!(Factory(:user)) }.should change(@email, :status).
      from(Newsletter::Status::PENDING).to(Newsletter::Status::SENT)
  end
end

