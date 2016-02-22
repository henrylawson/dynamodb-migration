require "dynamodb/migration/version"
require "dynamodb/migration/execute"
require "dynamodb/migration/unit"

module DynamoDB
  module Migration
    class << self
      DEFAULT_MIGRATION_TABLE_NAME = 'migrations'

      def migration_table_name
        @migration_table_name || DEFAULT_MIGRATION_TABLE_NAME
      end

      def migration_table_name=(name)
        @migration_table_name = name
      end

      def registered(app)
        options = {
          client: app.dynamodb_client,
          path:   app.settings.migrations_path,
        }
        run_all_migrations(options)
      end

      def run_all_migrations(options)
        Dir.glob("#{options[:path]}/**/*.rb").each do |file|
          require file
        end
        Execute.new(options[:client])
               .update_all
      end
    end
  end
end
