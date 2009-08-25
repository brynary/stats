module Oink
  module Metrics
    module Extensions
      module Memory
        def self.add_to(log)
          log.add Global.new(:memory_usage_total) { `ps -o rss= -p #{$$}`.to_i }
          log.add Change.new(:memory_usage, log.metric(:memory_usage_total))
        end
      end
    end
  end
end