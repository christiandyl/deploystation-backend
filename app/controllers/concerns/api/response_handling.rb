module Api
  module ResponseHandling
    extend ActiveSupport::Concern

    def render_args(result, success, code)
      args = {
        status: code,
        json: Oj.dump(
          success: success,
          result: result
        )
      }

      log_response(args)

      args
    end

    def response_ok(result = nil)
      render_args(result, true, 200)
    end

    def response_accepted(result)
      render_args(result, true, 202)
    end

    def response_created(result)
      render_args(result, true, 201)
    end

    def response_unprocessable_entity(result)
      render_args(result, false, 422)
    end

    def response_not_found(result)
      render_args(result, false, 404)
    end

    def response_unauthorized(result)
      render_args(result, false, 401)
    end

    def response_internal_server_error(result)
      render_args(result, false, 500)
    end

    def response_not_acceptable(result)
      render_args(result, false, 406)
    end

    def response_bad_request(result)
      render_args(result, false, 400)
    end

    def response_too_many_requests(result)
      render_args(result, false, 429)
    end

    private

    def log_response(args)
      controller = "#{params[:controller]}_controller".classify
      params = args.to_s
      message = "Rendering from #{controller} as JSON\nParameters: #{params}"

      Backend::Logger.debug(message)
    end
  end
end
