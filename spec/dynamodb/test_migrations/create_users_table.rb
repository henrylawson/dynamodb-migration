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
