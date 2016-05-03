module ApiDeploy
  class ContainerCheckerWorker
    include Sidekiq::Worker

    def perform(limit, offset)
      Container.online.limit(limit).offset(offset).each  do |c|
        container = Container.class_for(c.game.sname).find(c.id)
        hs = container.players_online(true)
        unless hs == false
          container.players = hs[:players_online].to_s + "/" + hs[:max_players].to_s
        end
      end
    end

  end
end