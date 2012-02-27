#YAML.add_domain_type("ActiveRecord,2010", "") do |type, val|
  #klass = type.split(':').last.constantize
  #YAML.object_maker(klass, val)
#end

#class ActiveRecord::Base
  #def to_yaml_type
    #"!ActiveRecord,2010/#{self.class}"
  #end

  #def to_yaml_properties
    #['@attributes']
  #end
#end
