module ApiDeploy
  module V1
    class ContainersController < ApplicationController

      before_filter :get_container, :except => [:index, :create]
      before_action :check_permissions, :except => [:index, :create, :destroy]
      before_action :check_super_permissions, :only => [:destroy]

      ##
      # Get containers list
      # @resource /v1/containers
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Container id
      # @response_field [Hash] result[].info Docker container info (blank by default)
      def index
        containers = current_user.containers.map do |c|
          c.to_api(:public)
        end

        render success_response containers
      end

      ##
      # Create container
      # @resource /v1/containers
      # @action POST
      #
      # @required [Hash] container
      # @required [Integer] container.plan_id Plan id
      # @required [String] container.name Server name
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [Integer] result.id Container id
      # @response_field [Hash] result.info Docker container info (blank by default)
      def create
        opts  = params.require(:container)
        plan_id  = opts[:plan_id] or raise ArgumentError.new("Plan id doesn't exists")
        name     = opts[:name] or raise ArgumentError.new("Name doesn't exists")
        
        plan = Plan.find(plan_id) or raise "Plan with id #{plan_id} doesn't exists"
        game = plan.game.name

        container = Container.class_for(game).create(current_user, plan)
        container.name = name
        container.save!

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
      # @response_field [String] result.name Docker container name
      def show
        render success_response @container.to_api(:public)
      end
  
      ##
      # Update container info
      # @resource /v1/containers/:container_id
      # @action PUT
      #
      # @optional [Hash] container
      # @optional [String] container.name Container name
      # @optional [Boolean] container.is_private Is private
      #
      # @response_field [Boolean] success
      def update
        opts = params.require(:container).permit(Container::PERMIT_LIST_UPDATE)
        
        @container.update(opts)
        Rails.logger.debug "Container-#{@container.id} info updated: #{opts.to_s}"
        
        render success_response
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
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] start
      # @response_field [PUSHER_SUCCESS_RESULT] { progress: [Float], message: [String] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { error: [Boolean] }
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
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] destroy
      # @response_field [PUSHER_SUCCESS_RESULT] { success: [Boolean] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: [Boolean] }
      def destroy
        @container.destroy_container
      
        render success_response
      end
      
      ##
      # Execute game server command
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
      
      ##
      # Get game server available commands list
      # @resource /v1/containers/:container_id/commands
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].name Command name
      # @response_field [Array] result[].required_args Command required arguments
      # @response_field [String] result[].required_args[].name Argument name
      # @response_field [String] result[].required_args[].title Argument title
      # @response_field [String] result[].required_args[].type Argument type
      # @response_field [Boolean] result[].required_args[].required Argument is required?
      def commands
        render success_response @container.class::COMMANDS
      end
    
      ##
      # Get game server online players list
      # @resource /v1/containers/:container_id/players_online
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] players_online
      # @response_field [PUSHER_SUCCESS_RESULT] { number_of_players: [Int], players_list: [List] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def players_online
        players_online = @container.players_online
        unless players_online
          raise "Can't get players online, server doesn't started"
        end
        
        render success_response
      end
      
      ##
      # Get game server logs list
      # @resource /v1/containers/:container_id/logs
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].date Command data
      # @response_field [String] result[].time Command time
      # @response_field [String] result[].type Command type
      # @response_field [String] result[].message Command message
      def logs
        logs = @container.logs
        
        render success_response logs
      end
    
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.name
      
        @container = Container.class_for(app).find(params[:id])
      end
      
      def check_permissions
        raise PermissionDenied unless @container.is_owner? current_user
      end
      
      def check_super_permissions
        raise PermissionDenied unless @container.is_super_owner? current_user
      end

    end
  end
end