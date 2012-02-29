namespace :db do
  desc 'Load the seed data from db/seeds.rb or vendor/e9_base/db/seeds.rb'
  task :seed => 'db:abort_if_pending_migrations' do
    seed_file = [Rails.root, E9Base::Engine.root].inject(nil) do |_, root|
      path = File.join(root, 'db', 'seeds.rb')
      break path if File.exist?(path)
    end

    if seed_file.present?
      puts "Loading seeds from #{seed_file}"
      load(seed_file)
    else
      puts "db:seed Failed: Neither db/seeds.rb nor vendor/e9_base/db/seeds.rb were found"
    end
  end
end
