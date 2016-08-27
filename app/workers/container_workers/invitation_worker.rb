module ContainerWorkers
  class InvitationWorker
    include Sidekiq::Worker

    def perform(container_id, invitation_method, invitation_data)
      begin
        container = Container.find(container_id)
        
        invitation = container.invitation(invitation_method, invitation_data)
        invitation.send(true)
        
        Pusher.trigger "container-#{container_id}", "invitation", { success: true }
      rescue => e
        Pusher.trigger "container-#{container_id}", "invitation", { success: false }
        raise e
      end
    end
    
  end
end