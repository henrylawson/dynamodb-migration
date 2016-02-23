module DynamoDB
  module Migration
    class Execute
      DEFAULT_MIGRATION_TABLE_NAME = 'migrations'

      def initialize(client, migration_table_name)
        @client = client
        @migration_table_name = migration_table_name
      end

      def update_all
        ensure_migrations_table_exists
        migration_classes.each do |clazz|
          apply_migration(clazz)
        end
      end

      private

      attr_reader :client

      def apply_migration(clazz)
        return if migration_executed?(clazz)
        record_start_migration(clazz)
        migration = clazz.new
        migration.client = client
        migration.update
        record_successful_migration(clazz)
      rescue Aws::DynamoDB::Errors::ServiceError => e
        record_failed_migration(clazz)
        raise
      end

      def record_failed_migration(clazz)
        client.delete_item({
          table_name: migration_table_name,
          key: {
            "file" => clazz_filename(clazz),
          },
          condition_expression: "completed = :false",
          expression_attribute_values: {
            ":false" => false
          }
        })
      end

      def record_start_migration(clazz)
        client.put_item({
          table_name: migration_table_name,
          item: {
            "file" => clazz_filename(clazz),
            "executed_at" => Time.now.iso8601,
            "created_at" => Time.now.iso8601,
            "updated_at" => Time.now.iso8601,
            "completed" => false,
          },
          return_values: "NONE",
        })
      end

      def record_successful_migration(clazz)
        client.update_item({
          table_name: migration_table_name,
          key: {
            "file" => clazz_filename(clazz),
          },
          update_expression: "SET completed = :true",
          condition_expression: "completed = :false",
          expression_attribute_values: {
            ":false" => false,
            ":true"  => true,
          }
        })
      end

      def clazz_filename(clazz)
        full_filename = clazz.instance_methods(false)
                             .map { |m| clazz.instance_method(m).source_location }
                             .compact
                             .map { |m| m.first }
                             .uniq
                             .first
        File.basename(full_filename)
      end

      def migration_classes
        ObjectSpace.each_object(DynamoDB::Migration::Unit.singleton_class)
                   .reject { |c| c == DynamoDB::Migration::Unit }
      end

      def migration_executed?(clazz)
        client.get_item({
          table_name: migration_table_name,
          key: {
            "file" => clazz_filename(clazz),
          },
          attributes_to_get: ["file"],
          consistent_read: true,
        }).item
      end

      def ensure_migrations_table_exists
        client.create_table(
          table_name: migration_table_name,
          attribute_definitions: [
            {
              attribute_name: "file",
              attribute_type: "S",
            },
          ],
          key_schema: [
            {
              attribute_name: "file",
              key_type: "HASH",
            },
          ],
          provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
          },
          stream_specification: {
            stream_enabled: true,
            stream_view_type: "NEW_AND_OLD_IMAGES",
          },
        ) unless table_exists?(client, migration_table_name)
      end

      def table_exists?(client, table_name)
        client.describe_table(table_name: table_name)
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException => e
        false
      end

      def migration_table_name
        @migration_table_name ||
          ENV['DYNAMODB_MIGRATION_TABLE_NAME'] ||
          DEFAULT_MIGRATION_TABLE_NAME
      end
    end
  end
end
