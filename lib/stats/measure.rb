class Stats
  module Measure
    def measure(prefix = nil, &block)
      result = nil

      tms = Benchmark.measure do
        result = block.call
      end

      add_time(prefix, tms)

      return result
    end
  end
end