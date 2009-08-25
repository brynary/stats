require "benchmark"

module Oink
  module Metrics

    class Timer < Metric

      def start
        @tms = Benchmark::Tms.new
      end

      def add_time(tms)
        @tms += tms
      end

      def field_names
        ["#{@name}_usr_time", "#{@name}_sys_time", "#{@name}_real_time"]
      end

      def values
        [
          (@tms.utime * 1_000).ceil,
          (@tms.stime * 1_000).ceil,
          (@tms.real * 1_000).ceil
        ]
      end

    end
  end
end