module Api
  module V1
    class ClientOptionsController < ApiController
      before_action :ensure_logged_in
      before_action :find_or_initialize_record, only: [:create, :show, :update, :destroy]
      before_action :extract_payload, :save_record, only: [:create, :update]
      before_action :save_record, only: [:create, :update]

      def index
        records = current_user.client_options.where(platform: client_platform)
        render response_ok records.to_api
      end

      def create
        render response_created
      end

      def show
        render response_ok @record.to_api
      end

      def update
        render response_ok
      end

      def destroy
        @record.destroy unless @record.new_record?

        render response_ok
      end

      # Callbacks

      def find_or_initialize_record
        @record = current_user.client_options.find_or_initialize_by(
          key: params[:key],
          platform: client_platform
        )
      end

      def extract_payload
        @payload = params.require(:client_option).permit(ClientOption::PERMIT)
      end

      def save_record
        @record.attributes = @payload
        @record.user = current_user
        @record.platform = client_platform

        @record.save!
      end
    end
  end
end
