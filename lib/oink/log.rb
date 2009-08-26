require "benchmark"

module Oink
  class Log

    def initialize(logger, extra_metadata = [])
      @logger = logger
      @metadata = default_metadata + extra_metadata
      Metrics::Extensions.add_to(self)
      write_headers
    end

    def default_metadata
      %w[transaction date time]
    end

    def write_headers
      write_header "Start-Date", Time.now.utc.strftime("%F %T")
      write_header "Fields", (@metadata + metrics.map(&:field_names)).join(" ")
    end

    def write_header(name, value)
      @logger.info "# #{name}: #{value}"
    end

    def reset
      @values = {
        :transaction => generate_transaction_id,
        :date => Time.now.utc.to_date,
        :time => Time.now.utc
      }
    end

    def add(metric)
      @metrics ||= {}
      @metrics[metric.name] = metric
    end

    def metric(name)
      @metrics[name]
    end

    def []=(key, value)
      @values[key.to_sym] = value
    end

    def transaction(&block)
      reset

      metrics.each(&:start)
      result = Oink.with_log(self, &block)
      metrics.each(&:stop)

      @logger.info log_line
      return result
    end

  protected

    def metrics
      @metrics.values.sort_by { |m| m.name.to_s }
    end

    def log_line
      (field_values + metric_values).map do |value|
        Formatter.format_value(value)
      end.join(" ")
    end

    def field_values
      @metadata.map { |field| @values[field.to_sym] }
    end

    def metric_values
      metrics.map(&:values).flatten
    end

    def generate_transaction_id
      "#{Time.now.to_i}-#{ActiveSupport::SecureRandom.hex(10)}"
    end

  end
end