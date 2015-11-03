module ApiDeploy
  module V1
    class ContainersController < ApplicationController

      before_filter :get_container, :except => [:create]

      ##
      # Create container
      # @resource /v1/containers
      # @action POST
      #
      # @required [Hash] container
      # @required [Integer] container.plan_id Plan id
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info (blank by default)
      def create
        opts  = params.require(:container)
        plan_id  = opts[:plan_id] or raise ArgumentError.new("Plan id doesn't exists")
        
        plan = Plan.find(plan_id) or raise "Plan with id #{plan_id} doesn't exists"
        game = plan.game.name

        container = Container.class_for(game).create(current_user, plan)

        render success_response container.to_api(:public)
      end
  
      ##
      # Get container info
      # @resource /v1/containers/:container_id
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info
      def show
        render success_response @container.to_api(:public)
      end
  
      ##
      # Start container
      # @resource /v1/containers/:container_id/start
      # @action POST
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info
      def start
        @container.start
      
        render success_response @container.to_api(:public)
      end
  
      ##
      # Restart container
      # @resource /v1/containers/:container_id/restart
      # @action POST
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info
      def restart
        @container.restart
      
        render success_response @container.to_api(:public)
      end
  
      ##
      # Stop container
      # @resource /v1/containers/:container_id/stop
      # @action POST
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info
      def stop
        @container.stop
      
        render success_response @container.to_api(:public)
      end

      ##
      # Destroy container
      # @resource /v1/containers/:container_id
      # @action DELETE
      #
      # @response_field [Boolean] success
      def destroy
        @container.destroy
      
        render success_response
      end
      
      ##
      # Execute local server command
      # @resource /v1/containers/:container_id/command
      # @action POST
      #
      # @required [Hash] command
      # @required [String] command.name Command name
      # @required [Hash] command.args Command arguments
      #
      # @response_field [Boolean] success
      def command
        opts = params.require(:command)
        
        command_name = opts["name"] or raise ArgumentError.new("Command name doesn't exists")
        command_args = opts["args"] or raise ArgumentError.new("Command args doesn't exists")

        @container.command(command_name, command_args)
        
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