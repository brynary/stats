class Stats
  class Middleware

    def initialize(app, stats)
      @app = app
      @stats = stats
    end

    def call(env)
      status, headers, body = nil
      
      @stats.transaction do
        @stats[:uri] = env["PATH_INFO"]
        @stats[:http_method] = env["REQUEST_METHOD"]
        
        if env["rack.routing_args"]
          @stats[:controller_name] = env["rack.routing_args"]["controller"]
          @stats[:action_name] = env["rack.routing_args"]["action"]
        end

        status, headers, body = @app.call(env)
        @stats[:response_code] = status
      end
      
      [status, headers, body]
    end

  end
end