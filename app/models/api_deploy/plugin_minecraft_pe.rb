module ApiDeploy
  class PluginMinecraftPe < GamePlugin 
    self.default_plugins = [
      {
        :id            => "1",
        :name          => 'Welcome',
        :author        => 'fromgate',
        :description   => "Authorization system supported SQLite, MySQL, YAML",
        :visible       => true,
        :repo_url      => 'http://forums.nukkit.cn/resources/welcome.4/',
        :download_url  => '',
        :dependencies  => ['DbLib'],
        :configuration => {}
      }, {
        :id            => "2",
        :name          => 'BlockProtect',
        :author        => 'fromgate',
        :description   => "Protect yourself from griefers by placing a protection block!",
        :visible       => true,
        :repo_url      => 'https://github.com/HiddenMotives/BlockProtect',
        :download_url  => 'https://github.com/HiddenMotives/BlockProtect/releases/download/1.0.0/BlockProtect.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "3",
        :name          => 'DbLib',
        :author        => 'fromgate',
        :description   => "DbLib is a library, that allows to get access to database simply",
        :visible       => false,
        :repo_url      => 'http://nukkit.ru/resources/dblib.14/',
        :download_url  => '',
        :dependencies  => [],
        :configuration => {}
      }
    ]
  end
end