namespace :e9 do
  namespace :email do
    desc "Deliver pending email scheduled for the current date"
    task :deliver_scheduled => :environment do
      Newsletter.deliver_scheduled
    end
  end
end
