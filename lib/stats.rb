require "stats/middleware"
require "stats/memory_usage"
require "stats/rails/sql_extensions"
require "stats/rails/active_record_extensions"
require "stats/rails/cache_extensions"
require "benchmark"

class Stats
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
    self[:transaction] = "1234"
    self[:date] = Time.now.utc.strftime("%F")
    self[:time] = Time.now.utc.strftime("%T")
    begin_memory = MemoryUsage.kilobytes
    measure(&block)
    end_memory = MemoryUsage.kilobytes
    self[:memory] = end_memory
    self[:memory_delta] = end_memory - begin_memory
    @logger.info log_line
    @values = {}
  end

  def measure(prefix = nil, &block)
    result = nil
    
    tms = Benchmark.measure do
      result = block.call
    end

    prefix = prefix.to_s + "_" if prefix

    self[prefix.to_s + "usr_time"] ||= 0.0
    self[prefix.to_s + "usr_time"] += tms.utime * 1_000

    self[prefix.to_s + "sys_time"]   ||= 0.0
    self[prefix.to_s + "sys_time"] += tms.stime * 1_000
    
    self[prefix.to_s + "real_time"]   ||= 0.0
    self[prefix.to_s + "real_time"] += tms.real * 1_000
    
    return result
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
    @fields.map do |field|
      @values[field] ? @values[field] : "-"
    end.join(" ")
  end
end