module E9::Liquid::Tags
  class For < Block
    Syntax = /(\w+)\s+in\s+([\w\.]+)/

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @variable_name   = $1
        @collection_name = $2
        @name = "#{$1}-#{$2}"
      else
        raise SyntaxError.new("Syntax Error in 'for loop' - Valid syntax: for [item] in [feed] [feed arguments]")
      end

      super
    end

    def render(context)        
      context.registers[:for] ||= Hash.new(0)

      begin
        obj = context[@collection_name] || @collection_name.classify.constantize
      rescue NameError
      end

      collection = build_collection(obj, context)
    
      return '' unless collection.respond_to?(:each) 
                                                 
      from = if @attributes['offset'] == 'continue'
        context.registers[:for][@name].to_i
      else
        context[@attributes['offset']].to_i
      end
        
      # if the context object is a drop, limit in the attributes is
      # actually limiting the SQL returned results and should be ignored
      to = unless Liquid::Drop === obj
        limit = context[@attributes['limit']]
        limit ? limit.to_i + from : nil  
      end
                       
      segment = slice_collection_using_each(collection, from, to)      
      
      return '' if segment.empty?
      
      result = []
        
      length = segment.length            
            
      # Store our progress through the collection for the continue flag
      context.registers[:for][@name] = from + segment.length
              
      context.stack do 
        segment.each_with_index do |item, index|     
          context[@variable_name] = item
          context['forloop'] = {
            'name'    => @name,
            'length'  => length,
            'index'   => index + 1, 
            'index0'  => index, 
            'rindex'  => length - index,
            'rindex0' => length - index -1,
            'first'   => (index == 0),
            'last'    => (index == length - 1) }

          result << render_all(@nodelist, context)
        end
      end

      result
    end          

    def build_collection(object, context)
      case object
      when Liquid::Drop
        object.respond_to?(:get) && object.get(@attributes) || []
      when Range
        object.to_a
      else
        if object.respond_to?(:liquid_find)
          object.liquid_find(context, @attributes)
        else
          object
        end
      end
    end

    def slice_collection_using_each(collection, from, to)
      segments = []
      index = 0
      yielded = 0

      collection.each do |item|
        break if to && to <= index
        segments << item if from <= index
        index += 1
      end

      segments
    end
  end

  Liquid::Template.register_tag('for', For)
end
