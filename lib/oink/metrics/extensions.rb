module Oink
  module Metrics
    module Extensions
      autoload :ActiveRecord, "oink/metrics/extensions/active_record"
      autoload :GC, "oink/metrics/extensions/garbage_collection"
      autoload :Memcached, "oink/metrics/extensions/memcached"
      autoload :Memory, "oink/metrics/extensions/memory"
      autoload :Objects, "oink/metrics/extensions/objects"
      autoload :Time, "oink/metrics/extensions/time"

      def self.add_to(log)
        [ActiveRecord, GC, Memcached, Memory, Objects, Time].each do |metric_module|
          metric_module.add_to(log)
        end
      end
    end
  end
end