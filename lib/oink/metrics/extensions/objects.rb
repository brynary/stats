module Oink
  module Metrics
    module Extensions
      module Objects
        def self.add_to(log)
          if ObjectSpace.respond_to?(:live_objects)
            log.add Global.new(:live_objects) { ObjectSpace.live_objects }
          end

          if ObjectSpace.respond_to?(:allocated_objects)
            log.add Global.new(:allocated_objects_total) { ObjectSpace.allocated_objects }
            log.add Change.new(:allocated_objects, log.metric(:allocated_objects_total))
          end
        end
      end
    end
  end
end