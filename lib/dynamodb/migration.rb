require "dynamodb/migration/version"
require "dynamodb/migration/execute"
require "dynamodb/migration/unit"

module DynamoDB
  module Migration
    def self.registered(app)
      options = {
        client: app.dynamodb_client,
        path:   app.settings.migrations_path,
      }
      run_all_migrations(options)
    end

    def self.run_all_migrations(options)
      Dir.glob("#{options[:path]}/**/*.rb").each do |file|
        require file
      end
      Execute.new(options[:client])
             .update_all
    end
  end
end
