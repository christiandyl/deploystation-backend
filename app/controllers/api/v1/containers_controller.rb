module Api
  module V1
    class ContainersController < ApiController
      skip_before_filter :ensure_logged_in, :only => [:search, :show]
      
      before_filter :get_container, :except => [:index, :shared, :create, :bookmarked, :popular, :search]
      before_action :check_permissions, :except => [:index, :shared, :create, :destroy, :bookmarked, :popular, :show, :search, :players_online]
      before_action :check_super_permissions, :only => [:destroy]
      before_filter :check_is_active, :except => [:index, :shared, :create, :bookmarked, :popular, :search, :show, :destroy]

      ##
      # Get popular containers
      # @resource /v1/popular_containers
      # @action GET
      #
      # @optional [Integer] page Page number, default: 1
      # @optional [Integer] per_page Per page items quantity, default: 15
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Container id
      # @response_field [Hash] result[].info Docker container info (blank by default)
      def popular
        list = Container.where(is_private: false, status: Container::STATUS_ONLINE)
        data = list.to_api(paginate: pagination_params)

        render response_ok data
      end

      ##
      # Search containers
      # @resource /v1/containers/search_containers
      # @action GET
      #
      # @required [String] query
      #
      # @optional [Integer] page Page number, default: 1
      # @optional [Integer] per_page Per page items quantity, default: 15
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Container id
      # @response_field [Hash] result[].info Docker container info (blank by default)
      def search
        query = params[:query] or raise "Search query is missing"
        raise "Query is blank" if query.blank?

        # Generating sql inputs
        condition = "containers.is_private is false and containers.status <> :status and "
        args      = { status: Container::STATUS_SUSPENDED }

        query.split(" ").each_with_index do |word, index|
          key = "q" + index.to_s
          condition  << "lower(containers.name) like :#{key} or lower(users.full_name) LIKE :#{key} or "
          args[key.to_sym] = "%#{word.downcase}%"
        end
        condition = condition[0..-4]

        # Getting experiences list
        list = Container.joins(:user).where(condition, args)
        data = list.to_api(paginate: pagination_params)

        render response_ok data
      end

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
          c.to_api
        end

        render response_ok containers
      end
      
      ##
      # Get shared containers list
      # @resource /v1/shared_containers
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Container id
      # @response_field [Hash] result[].info Docker container info (blank by default)
      def shared
        containers = current_user.shared_containers.map do |c|
          c.to_api
        end

        render response_ok containers
      end
      
      ##
      # Get bookmarked containers list
      # @resource /v1/bookmarked_containers
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Container id
      # @response_field [Hash] result[].info Docker container info (blank by default)
      def bookmarked
        containers = current_user.bookmarked_containers.map do |c|
          c.to_api
        end

        render response_ok containers
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
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] create
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true, result: [Hash] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false, result: {} }
      def create
        opts  = params.require(:container)
        plan_id  = opts[:plan_id] or raise ArgumentError.new("Plan id doesn't exists")
        name     = opts[:name] or raise ArgumentError.new("Name doesn't exists")
        
        plan = Plan.find(plan_id) or raise "Plan with id #{plan_id} doesn't exists"
        game = plan.game.sname
        host = plan.host
        
        # TODO need to fix in next ios build
        host_id = plan.host.id
        game_id = plan.game.id
        
        plans = Plan.where(host_id: host_id, game_id: game_id)
        plan = (plans.sort_by { |p| p.price.to_i }).first
        # TODO need to fix in next ios build

        unless host.available?
          # TODO add some conditions
          data = {
            :code    => 354,
            :message => "server is overloaded"
          }
          render response_too_many_requests data
        else
          container = Container.class_for(game).create(current_user, plan, name)

          render response_ok container.to_api
        end
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
      # @response_field [Boolean] result.bookmarked Bookmarked by user?
      def show
        args = @container.to_api
        unless current_user.nil?
          args[:owner] = @container.user_id == current_user.id
          if @container.user_id != current_user.id
            args[:bookmarked] = Bookmark.exists?(container_id: @container.id, user_id: current_user.id)
          end
        else
          args[:owner] = false
          args[:bookmarked] = false
        end
        
        # TO DO shit code
        # TO DO shit code
        # TO DO shit code
        args[:game_id] = @container.plan.game_id
        args[:active_until] = @container.active_until
        args[:has_plugins] = @container.has_plugins?
        # TO DO shit code
        # TO DO shit code
        # TO DO shit code

        render response_ok args
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
        
        render response_ok
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
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def start
        @container.start

        render response_ok @container.to_api
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
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] restart
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def restart
        @container.restart
      
        render response_ok @container.to_api
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
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] stop
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def stop
        @container.stop
      
        render response_ok @container.to_api
      end

      ##
      # Stop container
      # @resource /v1/containers/:container_id/reset
      # @action POST
      #
      # @response_field [Boolean] success
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] reset
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def reset
        @container.reset
      
        render response_ok
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
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def destroy
        @container.destroy_container
      
        render response_ok
      end
      
      ##
      # Get game command
      # @resource /v1/containers/:container_id/command
      # @action GET
      #
      # @required [String] command_id
      #
      # @response_field [Boolean] success
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] command_data
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true, result: [Hash] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def command
        id = params[:command_id] or raise ArgumentError.new("Command id doesn't exists")
        
        begin
          command = @container.commands.find { |c| c[:name] == id }
          requires_players = command[:requires_players]
        rescue
          requires_players = true
        end
        
        if @container.stopped?
          data = {
            :code    => 334,
            :message => "server is offline"
          }
          render response_bad_request data
        elsif requires_players == true && @container.players_list.blank?
        #elsif @container.players_list.blank? # TODO add normal players count validation
          data = {
            :code    => 333,
            :message => "server is empty"
          }
          render response_not_acceptable data
        else
          command = @container.command_data(id)
          render response_ok
        end
      end
      
      ##
      # Execute game server command
      # @resource /v1/containers/:container_id/execute_command
      # @action POST
      #
      # @required [Hash] command
      # @required [String] command.name Command name
      # @required [Hash] command.args Command arguments
      #
      # @response_field [Boolean] success
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] command
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true, result: [Hash] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def execute_command
        raise "Server should be running" if @container.stopped?
        
        opts = params.require(:command)
        
        command_name = opts["name"] or raise ArgumentError.new("Command name doesn't exists")
        # command_args = opts["args"] or raise ArgumentError.new("Command args doesn't exists")
        command_args = opts["args"]

        @container.command(command_name, command_args)
        
        render response_ok
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
        render response_ok @container.class::COMMANDS
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
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true, result: [Hash] }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def players_online
        players_online = @container.players_online
        # unless players_online
        #   raise "Can't get players online, server doesn't started"
        # end
        
        render response_ok
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
        
        render response_ok logs
      end
      
      ##
      # Get game server logs list
      # @resource /v1/containers/:container_id/invitation
      # @action POST
      #
      # @required [Hash] invitation
      # @required [String] invitation.method_name Method name (email,facebook,twitter...)
      # @required [Hash] invitation.data Invitation data
      #
      # @response_field [Boolean] success
      # @response_field [_________________________] _________________________
      # @response_field [PUSHER_CHANNEL_NAME] container-{id}
      # @response_field [PUSHER_KEY] invitation
      # @response_field [PUSHER_SUCCESS_RESULT] { success: true }
      # @response_field [PUSHER_UNSUCCESS_RESULT] { success: false }
      def invitation
        opts = params.require(:invitation)
        invitation_method = opts[:method_name] or raise ArgumentError.new("Invitation method name doesn't exists")
        invitation_data   = opts[:data] or raise ArgumentError.new("Invitation data doesn't exists")
        
        invitation = @container.invitation(invitation_method, invitation_data)
        invitation.send
        
        render response_ok
      end
    
      ##
      # Get referral token for container
      # @resource /v1/containers/:container_id/referral_token
      # @action GET
      #
      # @required [String] type Token type (extra_time,...)
      #
      # @response_field [Boolean] success
      # @response_field [String] result Referral token
      def referral_token # TODO add spec and conditions
        # extra_time
        type = params[:type] or raise ArgumentError
        
        referral_token = @container.referral_token_extra_time
        
        render response_ok referral_token
      end
      
      ##
      # Request new plan
      # @resource /v1/containers/:container_id/request_plan
      # @action POST
      #
      # @required [Hash] request_plan
      # @required [Integer] request_plan.plan_id Plan id
      #
      # @response_field [Boolean] success
      # TODO THERE ARE NO SPEC !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      def request_plan
        opts = params.require(:request_plan)
        plan_id = opts[:plan_id] or raise ArgumentError
        
        sr = SubscriptionRequest.create!({
          :user_id      => current_user.id,
          :container_id => @container.id,
          :plan_id      => plan_id,
          :status       => "new"
        })
        
        render response_ok
      end
    
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.sname
      
        @container = Container.class_for(app).find(params[:id])
      end
      
      def check_permissions
        raise PermissionDenied unless @container.is_owner? current_user
      end
      
      def check_super_permissions
        raise PermissionDenied unless @container.is_super_owner? current_user
      end
      
      def check_is_active
        raise "Container is not active" unless @container.active?
      end

    end
  end
end
