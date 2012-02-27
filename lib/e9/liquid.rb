module E9
  module Liquid
    TagStart       = /\{\%/
    TagEnd         = /\%\}/
    VariableStart  = /\{\{/
    VariableEnd    = /\}\}/
    TagAttributes  = /(\w+)\s*\[\s*([^\]]*)/
  end
end
