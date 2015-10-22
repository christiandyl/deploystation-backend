class ContainerMinecraft < Container
  
  REPOSITORY = 'overshard/minecraft'
  
  def self.create
    uuid = SecureRandom.uuid
    port = self.get_free_port
    
    super(
      'Image'        => REPOSITORY,
      'Cmd'          => '/start',
      "HostConfig" => { "Binds" => ["/mnt/#{uuid}:/data"] },
      "PortBindings" => { "25565/tcp": [{ "HostPort": port }] }
    )
  end
  
  def ban_user user_id
  end
  
  def unban_user user_id
  end
  
end