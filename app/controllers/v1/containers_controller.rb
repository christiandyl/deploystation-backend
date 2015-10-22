module V1
  class ContainersController < ApplicationController

    before_filter :get_container, :except => [:create]

    def create
      opts  = params.require(:container)
      game  = opts[:game] or raise ArgumentError.new("Game name doesn't exists")

      container = Container.class_for(game).create

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
      @container.delete(:force => true)
      
      render success_response @container.to_api(:public)
    end
    
    private
    
    def get_container
      @container = Container.get(params[:id])
    end

  end
end