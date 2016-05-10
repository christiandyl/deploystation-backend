Aws.config.update({
  :region      => Settings.aws.region,
  :credentials => Aws::Credentials.new(Settings.aws.key, Settings.aws.secret)
})