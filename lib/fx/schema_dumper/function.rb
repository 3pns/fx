require "rails"

module Fx
  module SchemaDumper
    # @api private
    module Function
      def tables(stream)
        functions(stream, :beggining)
        empty_line(stream, :beggining)

        super

        functions(stream, :end)
        empty_line(stream, :end)
      end

      def empty_line(stream, target)
        stream.puts if dumpable_functions_in_database(target).any?
      end

      def functions(stream, target)
        dumpable_functions_in_database(target).each do |function|

          stream.puts(function.to_schema)
        end
      end

      private
      def dumpable_functions_in_database(target)
        if Fx.configuration.dump_functions_at_beginning_of_schema and target == :beggining
          @_dumpable_functions_in_database_beggining  ||= Fx.database.functions.reject{ |fx| Fx.configuration.force_dump_functions_at_end_of_schema.include? fx.name } 
          return @_dumpable_functions_in_database_beggining
        elsif not Fx.configuration.dump_functions_at_beginning_of_schema and target == :beggining
          @_dumpable_functions_in_database_beggining  ||= Fx.database.functions.select{ |fx| Fx.configuration.force_dump_functions_at_beginning_of_schema.include? fx.name } 
          return @_dumpable_functions_in_database_beggining 
        elsif Fx.configuration.dump_functions_at_beginning_of_schema and target == :end
          @_dumpable_functions_in_database_end  ||= Fx.database.functions.select{ |fx| Fx.configuration.force_dump_functions_at_end_of_schema.include? fx.name } 
          return @_dumpable_functions_in_database_end
        elsif not Fx.configuration.dump_functions_at_beginning_of_schema and target == :end
          @_dumpable_functions_in_database_end ||= Fx.database.functions.reject{ |fx| Fx.configuration.force_dump_functions_at_beginning_of_schema.include? fx.name } 
          return @_dumpable_functions_in_database_end 
        end
        @_dumpable_functions_in_database 
      end
    end
  end
end
