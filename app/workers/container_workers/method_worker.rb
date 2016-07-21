module ContainerWorkers
  class MethodWorker
    include Sidekiq::Worker

    def perform(container_id, method_name, **args)
      method_args = args[:method_args] || {}

      container = Container.find(container_id).to_game_class
      container.send(method_name, method_args)
    end

  end
end