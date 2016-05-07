module ApiDeploy
  class ContainerCheckerWorker
    include Sidekiq::Worker

    def perform(limit, offset)
      Container.online.limit(limit).offset(offset).each  do |c|
        container = Container.class_for(c.game.sname).find_by_id(c.id)
        unless container.nil?
          hs = container.players_online(true)

          container.players = hs[:players_online].to_s + "/" + hs[:max_players].to_s
        
          Pusher.trigger("container-#{container.id}", "players_online", {
            :success => true,
            :result  => hs
          })
        end

      end
    end

  end
end