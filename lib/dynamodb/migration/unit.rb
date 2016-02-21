module DynamoDB
  module Migration
    class Unit
      attr_accessor :client

      def update
        raise 'Update method not implemented by migration class'
      end
    end
  end
end
