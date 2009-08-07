require "benchmark"

require "oink/middleware"
require "oink/memory_usage"
require "oink/measure"
require "oink/broadcaster"
require "oink/rails/sql_extensions"
require "oink/rails/active_record_extensions"
require "oink/rails/cache_extensions"

module Oink
  class Stats
    include Measure

    def self.broadcaster
      Broadcaster.new(active_stats)
    end

    def self.push(stats)
      active_stats.push(stats)
    end

    def self.pop
      active_stats.pop
    end

    def self.active_stats
      @active_stats ||= []
    end

    def initialize(fields, logger)
      @values = {}
      @logger = logger
      @fields = default_fields + fields.map { |f| f.to_s }

      @logger.info date_header
      @logger.info fields_header
    end

    def []=(key, value)
      @values[key.to_s] = value
    end

    def [](key)
      @values[key.to_s]
    end

    def incr(key)
      @values[key.to_s] ||= 0
      @values[key.to_s] += 1
    end

    def transaction(&block)
      self[:transaction] = generate_transaction_id
      self[:date] = Date.new(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day)
      self[:time] = Time.now.utc
      Stats.push(self)
      measure(&block)
      Stats.pop
      @logger.info log_line
      @values = {}
    end

    def measure(prefix = nil, &block)
      result = nil

      tms = Benchmark.measure do
        result = block.call
      end

      add_time(prefix, tms)

      return result
    end

    def add_time(prefix, tms)
      prefix = prefix.to_s + "_" if prefix

      self[prefix.to_s + "usr_time"] ||= 0.0
      self[prefix.to_s + "usr_time"] += tms.utime * 1_000

      self[prefix.to_s + "sys_time"]   ||= 0.0
      self[prefix.to_s + "sys_time"] += tms.stime * 1_000

      self[prefix.to_s + "real_time"]   ||= 0.0
      self[prefix.to_s + "real_time"] += tms.real * 1_000
    end

  protected

    def default_fields
      %w[transaction date time usr_time sys_time real_time]
    end

    def date_header
      "# Start-Date: " + Time.now.utc.strftime("%F %T")
    end

    def fields_header
      "# Fields: " + @fields.join(" ")
    end

    def log_line
      old_line
    end

    def old_line
      @fields.map do |field|
        format_value(@values[field])
      end.join(" ")
    end

    def generate_transaction_id
      "#{Time.now.to_i}-#{ActiveSupport::SecureRandom.hex(10)}"
    end

    def format_value(value)
      case value
      when nil
        "-"
      when Float
        "%.2f" % value
      when Time
        value.strftime("%T")
      when String
        quote(value)
      else
        value.to_s
      end
    end

    def quote(value)
      '"'                               +
      String(value).gsub('"', '"' * 2)  +
      '"'
    end
  end
end