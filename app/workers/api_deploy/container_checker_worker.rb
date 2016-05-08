module ApiDeploy
  class ContainerCheckerWorker
    include Sidekiq::Worker

    sidekiq_options unique: :all, queue: 'critical'

    def perform(limit, offset)
      Container.online.limit(limit).offset(offset).each  do |c|
        container = Container.class_for(c.game.sname).find_by_id(c.id)
        unless container.nil?
          hs = container.players_online(true)

          container.players = hs[:players_online].to_s + "/" + hs[:max_players].to_s
        
          channel_name = "container-#{container.id}"
        
          # TODO channel exists validation for slanger
          begin
            channels = Pusher.channels
            channel_exists = !channels[:channels][channel_name].nil? rescue false
          rescue
            channel_exists = true
          end
          
          if channel_exists
            Pusher.trigger(channel_name, "players_online", {
              :success => true,
              :result  => hs
            })
          end
        end

      end
    end

  end
end