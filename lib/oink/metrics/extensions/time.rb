module Oink
  module Metrics
    module Extensions
      module Time
        def self.add_to(log)
          log.add GlobalTimer.new
        end
      end
    end
  end
end