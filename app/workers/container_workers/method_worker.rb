module ContainerWorkers
  class MethodWorker
    include Sidekiq::Worker

    def perform(container_id, method_name, args=[])
      container = Container.find(container_id).to_game_class
      container.send(method_name, *args)
    end
  end
end
