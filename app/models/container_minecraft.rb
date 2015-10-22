class ContainerMinecraft < Container
  
  REPOSITORY = 'overshard/minecraft'
  
  def self.create
    super('Image' => REPOSITORY, 'Cmd' => '/start')
    # '-d=true -p=25565:25565 -v=/mnt/minecraft:/data overshard/minecraft /start'
    # TODO need to get know how to setup additional options
  end
  
  def ban_user user_id
  end
  
  def unban_user user_id
  end
  
end