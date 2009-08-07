require "benchmark"

require "oink/middleware"
require "oink/memory_usage"
require "oink/measure"
require "oink/broadcaster"
require "oink/rails/sql_extensions"
require "oink/rails/active_record_extensions"
require "oink/rails/cache_extensions"
require "oink/log"

module Oink

  def self.broadcaster
    Broadcaster.new(active_logs)
  end

  def self.active_logs
    @@active_logs ||= []
  end

end