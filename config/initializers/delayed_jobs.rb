require 'delayed_job'
Delayed::Worker.logger = Rails.logger

require 'active_record'

class ActiveRecord::Base
  def display_name
    self.class.name
  end
end
