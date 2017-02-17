[![Gem Version](https://badge.fury.io/rb/dynamodb-migration.svg)](https://badge.fury.io/rb/dynamodb-migration)
# DynamoDB::Migration

Allows for the creation of simple DynamoDB migrations that will be executed
only once against a DynamoDB database to allow you to "migrate" the schema of
the database over time. This is a simple implementation for DynamoDB, similar
to tools such as FlywayDB and Active Record Migrations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynamodb-migration'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamodb-migration

## Usage

In a rake task or in your applications start up, simply add:

```ruby
require 'dynamodb/migration'

options = {
  client: dynamodb_client,           # an Aws::DynamoDB::Client instance
  path: '/app/my_project/migrations', # the full path to the folder where your migration classes will live
  migration_table_name: 'migrations' # optional, the name of the table to use for migrations, default is "migrations"
}
DynamoDB::Migration.run_all_migrations(options)
```

Or if you are using a Sinatra application, in your `config.ru`:

```ruby
require 'dynamodb/migration'

# the full path to the folder where your migration classes will live
# we are assuming you will place your migrations in a "migrations" folder
# next to config.ru
set :migrations_path, File.join(File.dirname(__FILE__), 'migrations')

# optional, the name of the table to use for migrations, default is
# "migrations"
set :migration_table_name, 'migrations'

# registering the below requires the "dynamodb-client" gem, alternatively
# you can return a Aws::DynamoDB::Client instance from a method named
# `dynamodb_client`
register DynamoDB::Client

# registering this extension will automatically run migrations when the app
# starts up
register DynamoDB::Migration
```

To define a migration, create a class in your `migrations` folder (defined
above with the `path` option) such as the one below:


```ruby
# migrations/20150215181100_create_table_users.rb

class CreateTableUsers < DynamoDB::Migration::Unit
  def update
    client.create_table(
      table_name: "users",
      attribute_definitions: [
        {
          attribute_name: "username",
          attribute_type: "S",
        },
      ],
      key_schema: [
        {
          attribute_name: "username",
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
    )
  end
end
```

DynamoDB::Migration will detect this class and execute once against your
DynamoDB instance. It will record the execution in a table specified by the
option `:migration_table_name` (`migrations` by default) which it
creates and maintains internally.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/henrylawson/dynamodb-migration. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
