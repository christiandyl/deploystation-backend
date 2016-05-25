module ApiDeploy
  class PluginMinecraftPe < GamePlugin 
    self.default_plugins = [
      {
        :id            => 1,
        :name          => 'Welcome',
        :description   => "Authorization system supported SQLite, MySQL, YAML",
        :visible       => true,
        :dependencies  => ['DbLib'],
        :configuration => {}
      }, {
        :id            => 2,
        :name          => 'BlockProtect',
        :description   => "Protect yourself from griefers by placing a protection block!",
        :visible       => true,
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => 2,
        :name          => 'DbLib',
        :description   => "DbLib is a library, that allows to get access to database simply",
        :visible       => false,
        :dependencies  => [],
        :configuration => {}
      }
    ]
  end
end