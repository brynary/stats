module Oink
  module Metrics
    module Extensions
      module GC
        def self.add_to(log)
          if ::GC.respond_to?(:collections)
            log.add Global.new(:gc_runs_total) { ::GC.collections }
            log.add Change.new(:gc_runs, log.metric(:gc_runs_total))
          end

          if ::GC.respond_to?(:time)
            log.add Global.new(:gc_time_total) { (1_000 * ::GC.time).ceil }
            log.add Change.new(:gc_time, log.metric(:gc_time_total))
          end

          if ::GC.respond_to?(:allocated_size)
            log.add Global.new(:gc_malloc_total) { ::GC.allocated_size }
            log.add Change.new(:gc_malloc, log.metric(:gc_malloc_total))
          end
        end
      end
    end
  end
end