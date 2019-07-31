require "dynamodb/migration/version"
require "dynamodb/migration/execute"
require "dynamodb/migration/unit"

module DynamoDB
  module Migration
    class << self
      def registered(app)
        options = {
          client:                 app.dynamodb_client,
          path:                   app.settings.migrations_path,
          migration_table_name:   app.settings.migration_table_name,
        }
        run_all_migrations(options)
      end

      def run_all_migrations(options)
        Dir.glob("#{options[:path]}/**/*.rb").each do |file|
          require file
        end
        Execute.new(options[:client], options[:migration_table_name], options[:tags])
               .update_all
      end
    end
  end
end
