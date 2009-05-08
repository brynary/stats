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

        begin_memory = MemoryUsage.kilobytes
        status, headers, body = @app.call(env)
        end_memory = MemoryUsage.kilobytes

        @stats[:memory] = end_memory
        @stats[:memory_delta] = end_memory - begin_memory
        
        if env["rack.routing_args"]
          @stats[:controller_name]  = env["rack.routing_args"]["controller"]
          @stats[:action_name]      = env["rack.routing_args"]["action"]
        end

        @stats[:response_code] = status
      end

      [status, headers, body]
    end

  end
end