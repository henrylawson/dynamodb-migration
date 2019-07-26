require 'spec_helper'

describe DynamoDB::Migration do
  it 'has a version number' do
    expect(DynamoDB::Migration::VERSION).not_to be nil
  end

  before do
    ENV['AWS_ACCESS_KEY_ID'] ||= 'development'
    ENV['AWS_SECRET_ACCESS_KEY'] ||= 'development'
    ENV['AWS_REGION'] ||= 'us-east-1'
    ENV['AWS_DYNAMODB_ENDPOINT'] ||= 'http://192.168.99.100:8000/'
  end

  let(:client) { Aws::DynamoDB::Client.new(endpoint: ENV['AWS_DYNAMODB_ENDPOINT']) }

  let(:options) do
    {
      client: client,
      path: File.join(File.dirname(__FILE__), 'test_migrations')
    }
  end

  before do
    client.list_tables.table_names.each do |table_name|
      client.delete_table(table_name: table_name)
    end
  end

  it 'creates the users table' do
    expect(client.list_tables.table_names).to be_empty

    DynamoDB::Migration.run_all_migrations(options)

    expect(client.list_tables.table_names).to include('users')
  end

  it 'creates the sessions table' do
    expect(client.list_tables.table_names).to be_empty

    DynamoDB::Migration.run_all_migrations(options)

    expect(client.list_tables.table_names).to include('sessions')
  end

  it 'creates the all required tables' do
    expect(client.list_tables.table_names).to be_empty

    DynamoDB::Migration.run_all_migrations(options)

    expect(client.list_tables.table_names).to include('users', 'sessions')
  end

  it 'can be run multiple times without side effect' do
    expect(client.list_tables.table_names).to be_empty

    DynamoDB::Migration.run_all_migrations(options)
    DynamoDB::Migration.run_all_migrations(options)
    DynamoDB::Migration.run_all_migrations(options)

    expect(client.list_tables.table_names).to include('users', 'sessions')
  end

  it 'allows for custom migration table names' do
    custom_options = options.merge(migration_table_name: 'production_migrations')

    DynamoDB::Migration.run_all_migrations(custom_options)

    expect(client.list_tables.table_names).to contain_exactly('users',
                                                              'sessions',
                                                              'production_migrations')
  end
end
