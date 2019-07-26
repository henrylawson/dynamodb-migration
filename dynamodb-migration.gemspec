# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamodb/migration/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamodb-migration"
  spec.version       = DynamoDB::Migration::VERSION
  spec.authors       = ["Henry Lawson"]
  spec.email         = ["henry.lawson@foinq.com"]

  spec.summary       = %q{A simple DynamoDB migration tool.}
  spec.description   = %q{Allows for the creation of simple DynamoDB commands that will be executed only once against a DynamoDB database to allow you to "migrate" the schema of the database over time. This is a simple implementation for DynamoDB, similar to tools such as FlywayDB and Active Record Migrations.}
  spec.homepage      = "https://github.com/henrylawson/dynamodb-migration"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-dynamodb", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
