require 'inherited_resources'

module InheritedResources
  module PolymorphicHelpers
    private

      def symbols_for_association_chain #:nodoc:
        polymorphic_config = resources_configuration[:polymorphic]

        parents_symbols.map do |symbol|
          if symbol == :polymorphic
            params_keys = params.keys

            key = polymorphic_config[:symbols].find do |poly|
              params_keys.include? resources_configuration[poly][:param].to_s rescue false
            end

            if key.nil?
              raise ScriptError, "Could not find param for polymorphic association. The request" <<
                                 "parameters are #{params.keys.inspect} and the polymorphic " <<
                                 "associations are #{polymorphic_config[:symbols].inspect}." unless polymorphic_config[:optional]

              nil
            else
              @parent_type = key.to_sym
            end
          else
            symbol
          end
        end.compact
      end
  end
end
