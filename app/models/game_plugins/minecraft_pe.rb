module GamePlugins
  class MinecraftPe < GamePlugin 
    self.default_plugins = [
      {
        :id            => "1",
        :name          => 'Welcome',
        :author        => 'fromgate',
        :description   => "Authorization system supported SQLite, MySQL, YAML",
        :visible       => true,
        :repo_url      => 'http://forums.nukkit.cn/resources/welcome.4/',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/Welcome/Welcome.jar',
        :dependencies  => ['DbLib'],
        :configuration => {}
      }, {
        :id            => "2",
        :name          => 'BlockProtect',
        :author        => 'fromgate',
        :description   => "Protect yourself from griefers by placing a protection block!",
        :visible       => true,
        :repo_url      => 'https://github.com/HiddenMotives/BlockProtect',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/BlockProtect/BlockProtect.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "3",
        :name          => 'DbLib',
        :author        => 'fromgate',
        :description   => "DbLib is a library, that allows to get access to database simply",
        :visible       => false,
        :repo_url      => 'http://nukkit.ru/resources/dblib.14/',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/DbLib/DbLib.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "4",
        :name          => 'WorldEdit',
        :author        => 'CreeperFace',
        :description   => "Simple world editor for nukkit",
        :visible       => true,
        :repo_url      => 'https://forums.nukkit.io/resources/worldedit.64/',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/WorldEdit/WorldEdit.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "5",
        :name          => 'Cameraman',
        :author        => 'Prower',
        :description   => "Cameraman is an automatic motion control plugin",
        :visible       => true,
        :repo_url      => 'https://github.com/KsyMC/Cameraman',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/Cameraman/Cameraman.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "6",
        :name          => 'EconomyAPI',
        :author        => 'onebone',
        :description   => "Core of economy system for Nukkit",
        :visible       => true,
        :repo_url      => 'https://forums.nukkit.io/resources/economyapi.26/',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/EconomyAPI/EconomyAPI.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "7",
        :name          => 'Spawn',
        :author        => 'THEZAK',
        :description   => "With this simple plugin you can set spawn and teleport to spawn",
        :visible       => true,
        :repo_url      => 'https://forums.nukkit.io/resources/spawn.65/',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/Spawn/Spawn.jar',
        :dependencies  => [],
        :configuration => {}
      }, {
        :id            => "8",
        :name          => 'ItemKeeper',
        :author        => 'haniokasai',
        :description   => "With this simple plugin you can set spawn and teleport to spawn",
        :visible       => true,
        :repo_url      => 'https://github.com/haniokasai/ItemKeeper',
        :download_url  => 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/docker/minecraft_pe/plugins/ItemKeeper/ItemKeeper.jar',
        :dependencies  => [],
        :configuration => {}
      }
    ]
  end
end
