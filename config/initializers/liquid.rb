require 'liquid'
require 'e9'

E9::Liquid::Tags
E9::Liquid::Filters

#
# override liquid template to share registers across class
#
class Liquid::Template
  cattr_writer :registers

  def self.registers
    @@registers ||= {}
  end

  def registers
    self.class.registers
  end
end
