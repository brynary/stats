module Oink
  class Middleware

    def initialize(app, log)
      @app = app
      @log = log
    end

    def call(env)
      @log.transaction do
        status, headers, body = @app.call(env)

        @log[:uri] = env["PATH_INFO"]
        @log[:http_method] = env["REQUEST_METHOD"]
        @log[:response_code] = status

        if env["rack.routing_args"]
          @log[:controller_name] = env["rack.routing_args"]["controller"]
          @log[:action_name] = env["rack.routing_args"]["action"]
        end

        [status, headers, body]
      end
    end

  end
end