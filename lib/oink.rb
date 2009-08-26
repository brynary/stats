module Oink
  autoload :DummyLog, "oink/dummy_log"
  autoload :Formatter, "oink/formatter"
  autoload :Log, "oink/log"
  autoload :MethodTracker, "oink/method_tracker"
  autoload :Metrics, "oink/metrics"
  autoload :Middleware, "oink/middleware"
  autoload :RackLog, "oink/rack_log"

  def self.measure(name, &block)
    result = nil

    tms = Benchmark.measure do
      result = block.call
    end

    metrics(name).each { |metric| metric.add_time(tms) }
    return result
  end

  def self.incr(name)
    metrics(name).each(&:incr)
  end

  def self.metrics(name)
    active_logs.map { |log| log.metric(name) }.compact
  end

  def self.with_log(log)
    active_logs.push(log)
    result = yield
    active_logs.pop
    return result
  end

  def self.active_logs
    @@active_logs ||= []
  end

end