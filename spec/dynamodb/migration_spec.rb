require 'spec_helper'

describe Dynamodb::Migration do
  it 'has a version number' do
    expect(Dynamodb::Migration::VERSION).not_to be nil
  end

  before do
    ENV['AWS_ACCESS_KEY_ID'] = 'development'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'development'
    ENV['AWS_REGION'] = 'us-east-1'
    ENV['AWS_DYNAMODB_ENDPOINT'] = 'http://192.168.99.100:8000/'
  end
end
