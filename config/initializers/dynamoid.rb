Dynamoid.configure do |config|
  # This adapter establishes a connection to the DynamoDB servers using Amazon's own AWS gem.
  config.adapter = 'aws_sdk_v2'
  # To namespace tables created by Dynamoid from other tables you might have. Set to nil to avoid namespacing.
  config.namespace = Settings.aws.dynamo_db.namespace
  # Output a warning to the logger when you perform a scan rather than a query on a table.
  config.warn_on_scan = true
  # Read capacity for your tables
  config.read_capacity = 5
  # Write capacity for your tables
  config.write_capacity = 5
  # [Optional]. If provided, it communicates with the DB listening at the endpoint. This is useful for testing with [Amazon Local DB]
  # (http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html). 
  # config.endpoint = 'http://localhost:3000'
end