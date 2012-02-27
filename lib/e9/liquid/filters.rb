module E9::Liquid::Filters
end

Dir["#{File.dirname(__FILE__)}/filters/*.rb"].each {|file| require file }
