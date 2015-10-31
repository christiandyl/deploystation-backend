module ApiDeploy
  module V1
    class ContainersController < ApplicationController

      before_filter :get_container, :except => [:create]

      def create
        opts  = params.require(:container)
        plan_id  = opts[:plan_id] or raise ArgumentError.new("Plan id doesn't exists")
        
        plan = Plan.find(plan_id) or raise "Plan with id #{plan_id} doesn't exists"
        game = plan.game.name

        container = Container.class_for(game).create(current_user, plan)

        render success_response container.to_api(:public)
      end
  
      def show
        render success_response @container.to_api(:public)
      end
  
      def start
        @container.start
      
        render success_response @container.to_api(:public)
      end
  
      def restart
        @container.restart
      
        render success_response @container.to_api(:public)
      end
  
      def stop
        @container.stop
      
        render success_response @container.to_api(:public)
      end

      def destroy
        @container.destroy
      
        render success_response
      end
    
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.name
      
        @container = Container.class_for(app).find(params[:id])
      end

    end
  end
end