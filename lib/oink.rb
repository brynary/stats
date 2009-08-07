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

  end
end